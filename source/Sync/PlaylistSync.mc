class PlaylistSync extends Deferrable {

	private var d_provider = SubMusic.Provider.get();
	private var d_iplaylist;	
	
	private var d_failed = false;	// true if anything failed
	
	private var f_progress; 		// callback on progress

	function initialize(id, progress, done, fail) {
		if ($.debug) {
			System.println("PlaylistSync::initialize()");
		}
		Deferrable.initialize(method(:sync), done, fail);		// make sync the deferred task
		
		f_progress = progress;
		
        d_provider.setFallback(method(:onError));
		d_provider.setProgressCallback(method(:onProgress));
        
		d_iplaylist = new IPlaylist(id);
	}
	
	function sync() {
		// if desired local, update playlist info
    	if (d_iplaylist.local()) {
			d_provider.getPlaylist(d_iplaylist.id(), method(:onGetPlaylist));
			return Deferrable.defer();
   		}

    	// unlink songs if playlist not desired locally
		d_iplaylist.unlink();
		d_iplaylist.remove();
		
		return Deferrable.complete();		// indicate completed
	}
	
	function onGetPlaylist(response) {

		// mark first out of 2 requests done
		onProgress(1/2);
		
		if (response.size() == 0) {
			// playlist not found on server
			d_iplaylist.setRemote(false);
		} else {
			// update metadata of current playlist
			d_iplaylist.updateMeta(response[0]);
		}

		// if desired locally and available remotely, make request for updating songs
    	if (d_iplaylist.remote()) {
    		d_iplaylist.link();
    		d_provider.getPlaylistSongs(d_iplaylist.id(), method(:onGetPlaylistSongs));
    		return;
    	}
    	
		d_iplaylist.setSynced(!d_failed);	// not failed = successful sync
   		Deferrable.complete();				// set sync complete
	}
	
	function onGetPlaylistSongs(songs) {
		// mark 2 out of 2 requests done
		onProgress(2/2);

		// update the playlist with remote songs
    	d_iplaylist.update(songs);			// returns new remote songs, not used
		d_iplaylist.setSynced(!d_failed);	// not failed = successful sync
		Deferrable.complete();				// set sync complete
	}

	// handle callback on intermediate progress
	function onProgress(progress) {
		f_progress.invoke(progress);
	}
    
    function onError(error) {
    	if ($.debug) {
    		System.println("PlaylistSync::onError(" + error.shortString() + " : " + error.toString() + ")");
    	}

    	// indicate failed sync
//   	d_iplaylist.setError(error); TODO
    	d_failed = true;
	    d_iplaylist.setSynced(!d_failed);

		// 'not found' can return through api or http status codes
		var api_not_found = (error instanceof SubMusic.ApiError)
						&& (error.api_type() == SubMusic.ApiError.NOTFOUND);
		var http_not_found = (error instanceof SubMusic.HttpError)
						&& (error.http_type() == SubMusic.HttpError.NOT_FOUND);

		if (api_not_found || http_not_found) {

			// update remote status
			d_iplaylist.setRemote(false);
			Deferrable.complete();
			return;
		}

		if ((error instanceof SubMusic.GarminSdkError)
			&& (error.respCode() == Communications.NETWORK_RESPONSE_TOO_LARGE)) {
			Deferrable.complete();
			return;
		}

		Deferrable.cancel(error);
		return;
    }
}