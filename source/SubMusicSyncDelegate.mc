using Toybox.Application;
using Toybox.Communications;
using Toybox.Media;

// Performs the sync with the music provider
class SubMusicSyncDelegate extends Media.SyncDelegate {

    // playlists to sync
    private var d_todo;				// array of playlist ids
    private var d_todo_total = 0;
    private var d_todo_songs;		// array of song ids  
    private var d_songs_total = 0;

	// mark true if a song failed
	private var d_failed = false;
    
    // front iplaylist
    private var d_playlist;
	private var d_song;
    
    // api access
    private var d_provider;

    // Constructor
    function initialize(provider) {
        SyncDelegate.initialize();
        
        d_provider = provider;
        d_provider.setFallback(method(:onFail));
    }

    // Starts the sync with the system
    function onStartSync() {
        System.println("Sync started...");
		updateProgress();

		// starting sync
        d_todo = PlaylistStore.getIds();
        d_todo_total = d_todo.size();

		// iterate over the playlists
        syncNextPlaylist();
    }
    
    function syncNextPlaylist() {
    	// return if completely done
    	if (d_todo.size() == 0) {
    		// finalize removals (deletes are deferred, to prevent redownloading)
			var todelete = SongStore.getDeletes();
			for (var idx = 0; idx < todelete.size(); ++idx) {
				var id = todelete[idx];
				var isong = new ISong(id);
				isong.setRefId(null);			// delete from cache
				isong.remove();					// remove from Store
			}
    		
			// reset the fallback function
    		d_provider.setFallback(method(:onFail));

        	System.println("Sync completed...");

			// finish sync
    		Media.notifySyncComplete(null);
    		return;
    	}
    	d_playlist = new IPlaylist(d_todo[0]);
		d_failed = false;						// mark
    	
    	// if desired local, update playlist info
    	if (d_playlist.local()) {
			d_provider.getPlaylist(d_playlist.id(), method(:onGetPlaylist));
			return;
   		}

		// modify progress if playlist was not linked
		if (!d_playlist.linked()) {
			d_todo_total -= 1;
		}

    	// unlink songs if playlist not desired locally
		d_playlist.unlink();
		d_playlist.remove();

		// continue to next playlist
		d_todo.remove(d_todo[0]);
		syncNextPlaylist();
    }

	function onGetPlaylist(response) {
		
		if (response.size() == 0) {
			// playlist not found on server
			d_playlist.setRemote(false);
		} else {
			// update metadata of current playlist
			d_playlist.updateMeta(response[0]);
		}

		// if desired locally and available remotely, make request for updating songs
    	if (d_playlist.remote()) {
    		d_playlist.link();
    		d_provider.getPlaylistSongs(d_playlist.id(), method(:onGetPlaylistSongs));
    		return;
    	}
    	
		d_playlist.setSynced(!d_failed);	// not failed = successful sync

   		// continue to next playlist
   		d_todo.remove(d_todo[0]);
   		syncNextPlaylist();
	}
    
    function onGetPlaylistSongs(songs) {

		// count the total number of songs on this playlist
    	d_songs_total = songs.size();

		// retrieve array of ids of non local songs
    	d_todo_songs = d_playlist.update(songs);
    	
    	// update progress bar
    	updateProgress();
    	
		// update fallback
		d_provider.setFallback(method(:onSongDownloadFail));
   		syncNextSong();
    }
    
    function syncNextSong() {

		// if songs not all finished, start the download
		if (d_todo_songs.size() != 0) {
			d_song = new ISong(d_todo_songs[0]);
			d_provider.getRefId(d_song.id(), d_song.mime(), method(:onSongDownloaded));
			return;
		}

		// reset the fallback
		d_provider.setFallback(method(:onFail));

		// all songs finished
		d_playlist.setSynced(!d_failed);	// not failed = successful sync
		// continue to next playlist
		d_todo.remove(d_todo[0]);
		syncNextPlaylist();
	}

    // Callback for when a song is downloaded
	function onSongDownloaded(refId) {
		// update refId
		d_song.setRefId(refId);
		
		// continue to next song
		d_todo_songs.remove(d_todo_songs[0]);
		updateProgress();
		
		syncNextSong();
	}

    // fallback for failed download
	function onSongDownloadFail(responseCode, data) {
		
		System.println("Sync failed " + d_todo_songs[0]);

		// mark a failed download
		d_failed = true;
    	
    	// remove first element from todo list
    	d_todo_songs.remove(d_todo_songs[0]);
		updateProgress();

    	syncNextSong();
    }

    function updateProgress() {
    	if (d_todo_total == 0) {
    		Media.notifySyncProgress(0);					// 0% progress
    		return;
    	}
    	// major progress based on playlist count
    	var major_step = 100 / d_todo_total.toFloat();
    	var major_progress = major_step * (d_todo_total - d_todo.size());

		// minor progress based on song count on current playlist
		var minor_progress;
		var minor_step;
		if (d_songs_total == 0) {
			minor_progress = major_step;
		} else {
			minor_step = (major_step / d_songs_total.toFloat());
			minor_progress = minor_step * (d_songs_total - d_todo_songs.size());
		}
		var progress = (major_progress + minor_progress).toNumber();
		System.println("UpdateProgress: " 
						+ major_progress 
						+ " + " 
						+ minor_progress 
						+ " = " 
						+ progress
						+ " | "
						+ minor_step
						+ " minor step, "
						+ (d_songs_total) 
						+ " songs total, "
						+ d_todo_songs.size()
						+ " size of todo");
    	Media.notifySyncProgress(progress);
    }
    
    // fallback for API failures
    function onFail(responseCode, data) {

		// check for playlist id not found error (setRemote(false))
		if ((responseCode == 200) 				// general error
				|| (responseCode == 400)) {		// Ampache error
			d_failed = true;
			onGetPlaylist([]);
			return;
		}

    	System.println("ResponseCode: " + responseCode + " payload " + data);
    	var msg = "Error code: " + responseCode + "\n";
    	msg += respCodeToString(responseCode) + "\n";
    	Media.notifySyncComplete(responseCode.toString());
    }

    // Sync always needed to verify new songs on the server
    function isSyncNeeded() {
        return true;
    }
    
	// move to somewhere else later, but now this is one of the two places this is used
    function respCodeToString(responseCode) {
    	if (responseCode == Communications.INVALID_HTTP_HEADER_FIELDS_IN_REQUEST) {
    		return "\"INVALID_HTTP_HEADER_FIELDS_IN_REQUEST\"";
    	} else if (responseCode == Communications.INVALID_HTTP_BODY_IN_REQUEST) {
    		return "\"INVALID_HTTP_BODY_IN_REQUEST\"";
    	} else if (responseCode == Communications.INVALID_HTTP_METHOD_IN_REQUEST) {
    		return "\"INVALID_HTTP_METHOD_IN_REQUEST\"";
    	} else if (responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
    		return "\"NETWORK_REQUEST_TIMED_OUT\"";
    	} else if (responseCode == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
    		return "\"INVALID_HTTP_BODY_IN_NETWORK_RESPONSE\"";
    	} else if (responseCode == Communications.INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE) {
    		return "\"INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE\"";
    	} else if (responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE) {
    		return "\"NETWORK_RESPONSE_TOO_LARGE\"";
    	} else if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
    		return "\"NETWORK_RESPONSE_OUT_OF_MEMORY\"";
    	} else if (responseCode == Communications.STORAGE_FULL) {
    		return "\"STORAGE_FULL\"";
    	} else if (responseCode == Communications.SECURE_CONNECTION_REQUIRED) {
    		return "\"SECURE_CONNECTION_REQUIRED\"";
    	}
    	return "Unknown";
    }
}
