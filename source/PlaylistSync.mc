class PlaylistSync extends Deferrable {

	private var d_provider;
	private var d_playlist;
	private var d_song = null;		// front of the todos
	
	
	private var d_failed = false;	// true if anything failed
	
	private var f_progress; 		// callback on progress
	
	// store sync size
	private var d_todo_songs = [];
	private var d_todo_total;		// the number of items that had to be synced

	function initialize(provider, id, progress) {
		Deferrable.initialize(method(:sync));		// make sync the deferred task
		
		f_progress = progress;
		
		d_provider = provider;
        d_provider.setFallback(method(:onError));
        
		d_playlist = new IPlaylist(id);
		d_todo_total = d_playlist.count();
	}
	
	function sync() {
		// if desired local, update playlist info
    	if (d_playlist.local()) {
			d_provider.getPlaylist(d_playlist.id(), method(:onGetPlaylist));
			return Deferrable.defer();
   		}

		// modify progress if playlist was not linked
		if (!d_playlist.linked()) {
			d_todo_total = 0;
		}

    	// unlink songs if playlist not desired locally
		d_playlist.unlink();
		d_playlist.remove();
		
		return Deferrable.complete();		// indicate completed
	}
	
	function onProgress() {
		// TODO: progress callback in requests, since v3.2
		return ;
	}
	
	function onGetPlaylist(response) {
		
		if (response.size() == 0) {
			// playlist not found on server
			d_playlist.setRemote(false);
		} else {
			// update metadata of current playlist
			d_playlist.updateMeta(response[0]);
		}
		
		// update todo count
		d_todo_total = d_playlist.count();

		// if desired locally and available remotely, make request for updating songs
    	if (d_playlist.remote()) {
    		d_playlist.link();
    		d_provider.getPlaylistSongs(d_playlist.id(), method(:onGetPlaylistSongs));
    		return;
    	}
    	
		d_playlist.setSynced(!d_failed);	// not failed = successful sync
   		Deferrable.complete();
	}
	
	function onGetPlaylistSongs(songs) {
		// count the total number of songs on this playlist
    	d_todo_total = songs.size();

		// retrieve array of ids of non local songs
    	d_todo_songs = d_playlist.update(songs);
    	
		// update fallback
		d_provider.setFallback(method(:onError));
   		syncNextSong();
	}
	
	function syncNextSong() {
		var done = d_todo_total - d_todo_songs.size();
		var progress = (100 * done) / d_todo_total.toFloat();
		f_progress.invoke(progress);

		// if songs not all finished, start the download
		if (d_todo_songs.size() != 0) {
			d_song = new ISong(d_todo_songs[0]);
			d_provider.getRefId(d_song.id(), d_song.mime(), method(:onSongDownloaded));
			return;
		}

		// reset the fallback
		d_provider.setFallback(method(:onError));

		// all songs finished
		d_playlist.setSynced(!d_failed);	// not failed = successful sync
   		Deferrable.complete();
	}
	
    // Callback for when a song is downloaded
	function onSongDownloaded(refId) {
		// update refId
		d_song.setRefId(refId);
		
		// continue to next song
		d_todo_songs.remove(d_todo_songs[0]);
		
		syncNextSong();
	}
    
    function onError(error) {
    	
    	// indicate failed sync
//   	d_playlist.setError(error); TODO
    	d_failed = true;
    	
    	// check if song in progress
    	if (d_song != null) {
    		// record the cause of failure
//	    	d_song.setError(error);				TODO
	    	
	    	// remove first element from todo list
	    	d_todo_songs.remove(d_todo_songs[0]);
	
	    	syncNextSong();
    		return;
    	}
    	
    	// update playlist info if not found
    	if (error.type() == SubMusic.ApiError.NOTFOUND) {
    		d_playlist.setRemote(false);
    	}
    	
    	d_playlist.setSynced(!d_failed);
    	Deferrable.complete(); 	
    }
}