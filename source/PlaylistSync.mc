class PlaylistSync extends Deferrable {

	private var d_provider;
	private var d_playlist;
	private var d_song = null;		// front of the todos
	
	
	private var d_failed = false;	// true if anything failed
	
	private var f_progress; 		// callback on progress
	private var d_fallback;			// fallback on unhandled error
	
	// store sync size
	private var d_todo_songs = null;
	private var d_todo_total;		// the number of items that had to be synced

	function initialize(provider, id, progress) {
		Deferrable.initialize(method(:sync));		// make sync the deferred task
		
		f_progress = progress;
		
		d_provider = provider;
        d_provider.setFallback(method(:onError));
		d_provider.setProgressCallback(method(:onProgress));
        
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
   		Deferrable.complete();				// set sync complete
	}
	
	function onGetPlaylistSongs(songs) {
		// retrieve array of ids of non local songs
    	d_todo_songs = d_playlist.update(songs);
    	
		// count the number of songs on this playlist that need a download
    	d_todo_total = d_todo_songs.size();
    	
   		syncNextSong();
	}
	
	function progress() {
		// determine what is left to do
		var todo = 0;
		if (d_todo_songs != null) { todo = d_todo_songs.size(); }
		
		var done = d_todo_total - todo;
		var progress = (100 * done) / d_todo_total.toFloat();
		return progress;
	}

	// handle callback on intermediate progress
	function onProgress(progress) {
		progress /= d_todo_total.toFloat();
		f_progress.invoke(progress() + progress);
	}
	
	function syncNextSong() {

		// if songs all finished, complete this task
		if (d_todo_songs.size() == 0) {
			d_playlist.setSynced(!d_failed);	// not failed = successful sync
	   		Deferrable.complete();				// set complete
			return;
		}

		// update progress
		f_progress.invoke(progress());
		
		// start download
		d_song = new ISong(d_todo_songs[0]);
		d_provider.getRefId(d_song.id(), d_song.mime(), method(:onSongDownloaded));
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
			d_song = null;
	    	
	    	// remove first element from todo list
	    	d_todo_songs.remove(d_todo_songs[0]);
	
	    	syncNextSong();
    		return;
    	}
    	
	    d_playlist.setSynced(!d_failed);
    	
    	// update playlist info if not found
    	if ((error instanceof SubMusic.ApiError)
    		&& (error.type() == SubMusic.ApiError.NOTFOUND)) {
    		d_playlist.setRemote(false);
	    	Deferrable.complete();
	    	return; 	
    	}
    	
    	// other errors will break the sync by default
    	Deferrable.cancel(error);
    	return;
    }
}