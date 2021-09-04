class AudioSync extends Deferrable {

	private var d_provider = SubMusic.Provider.get();
	private var d_audio = null;		// front of the todos
	
	private var d_failed = [];		// array of all failed
	
	private var f_progress; 		// callback on progress
	
	// store sync size
	private var d_todo = [];		// array of IAudio objects
	private var d_todo_total;		// the number of items that had to be synced

	function initialize(progress, done, fail) {
		Deferrable.initialize(method(:sync), done, fail);		// make sync the deferred task
		
		f_progress = progress;
		
        d_provider.setFallback(method(:onError));
		d_provider.setProgressCallback(method(:onProgress));

		// first delete the todeletes
		var ids = SongStore.getDeletes();
		for (var idx = 0; idx < ids.size(); ++idx) {
			var id = ids[idx];
			var isong = new ISong(id);
			isong.remove();					// remove from Store
		}
		
		// now get the todos from songs and episodes
		var types = [ "song", "podcast"];
		ids = [ SongStore.getIds(), EpisodeStore.getIds() ];
		for (var typ = 0; typ != types.size(); ++typ) {
				System.println(typ);
			for (var idx = 0; idx != ids[typ].size(); ++idx) {
				System.println(idx);
				var audio = new Audio(ids[typ][idx], types[typ]);

				// only add to todo if not yet stored
				if (audio.refId() == null) {
					d_todo.add(audio);
				}
			}
		}
		d_todo_total = d_todo.size();
	}
	
	function sync() {
		// if songs all finished, complete this task
		if (d_todo.size() == 0) {
	   		return Deferrable.complete();				// set complete
		}

		// update progress
		f_progress.invoke(progress());
		
		// start download
		d_provider.getRefId(d_todo[0].id(), d_todo[0].mime(), d_todo[0].type(), method(:onDownloaded));
		return Deferrable.defer();
	}

	function progress() {
		// determine what is left to do
		var todo = 0;
		if (d_todo != null) { todo = d_todo.size(); }
		
		var done = d_todo_total - todo;
		var progress = (100 * done) / d_todo_total.toFloat();
		return progress;
	}

	// handle callback on intermediate progress
	function onProgress(progress) {
		progress /= d_todo_total.toFloat();
		f_progress.invoke(progress() + progress);
	}
	
    // Callback for when a song is downloaded
	function onDownloaded(refId) {
		// update refId
		d_todo[0].setRefId(refId);

		// continue to next song
		d_todo.removeAll(d_todo[0]);
	
		sync();
	}
    
    function onError(error) {
    	System.println("AudioSync::onError(" + error.shortString() + " : " + error.toString() + ")");

    	// indicate failed sync
//   	d_playlist.setError(error); TODO
    	d_failed.add(d_todo[0]);
    	
    	// check if song in progress
		if (d_todo[0] == null) {
			Deferrable.cancel(error);
			return;
		}
		// record the cause of failure
//	    	d_todo[0].setError(error);				TODO
		
		// remove first element from todo list
		d_todo.removeAll(d_todo[0]);

		sync();
		return;
    }
}