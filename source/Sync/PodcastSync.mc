class PodcastSync extends Deferrable {

	private var d_provider = SubMusic.Provider.get();
	private var d_ipodcast;	
	
	private var d_failed = false;	// true if anything failed
	
	private var f_progress; 		// callback on progress

	function initialize(id, progress, done, fail) {
		Deferrable.initialize(method(:sync), done, fail);		// make sync the deferred task
		
		f_progress = progress;
		
        d_provider.setFallback(method(:onError));
		d_provider.setProgressCallback(method(:onProgress));
        
		d_ipodcast = new IPodcast(id);
	}
	
	function sync() {
		// if desired local, update podcast info
    	if (d_ipodcast.local()) {
			d_provider.getPodcast(d_ipodcast.id(), method(:onGetPodcast));
			return Deferrable.defer();
   		}

    	// unlink episodes if podcast not desired locally
		d_ipodcast.unlink();
		d_ipodcast.remove();
		
		return Deferrable.complete();		// indicate completed
	}
	
	function onGetPodcast(response) {
		System.println(response.toString());
		// mark first out of 2 requests done
		onProgress(1/2);
		
		if (response.size() == 0) {
			// podcast not found on server
			d_ipodcast.setRemote(false);
		} else {
			// update metadata of current podcast
			d_ipodcast.updateMeta(response[0]);
		}

		// if desired locally and available remotely, make request for updating episodes
    	if (d_ipodcast.remote()) {
    		d_ipodcast.link();
    		d_provider.getEpisodes(d_ipodcast.id(), [0,1], method(:onGetEpisodes));
    		return;
    	}
    	
		d_ipodcast.setSynced(!d_failed);	// not failed = successful sync
   		Deferrable.complete();				// set sync complete
	}
	
	function onGetEpisodes(episodes) {
		// mark 2 out of 2 requests done
		onProgress(2/2);

		// update the podcast with remote songs
    	d_ipodcast.update(episodes);		// returns new remote episodes, not used
		d_ipodcast.setSynced(!d_failed);	// not failed = successful sync
   		Deferrable.complete();				// set sync complete
	}

	// handle callback on intermediate progress
	function onProgress(progress) {
		f_progress.invoke(progress);
	}
    
    function onError(error) {
    	System.println("PodcastSync::onError(" + error.shortString() + " : " + error.toString() + ")");

    	// indicate failed sync
//   	d_ipodcast.setError(error); TODO
    	d_failed = true;
	    d_ipodcast.setSynced(!d_failed);

		if ((error instanceof SubMusic.ApiError)
			&& (error.api_type() == SubMusic.ApiError.NOTFOUND)) {

			// update remote status
			d_ipodcast.setRemote(false);
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