class ArtworkSync extends Deferrable {

	private var d_provider = SubMusic.Provider.get();
	
	// private var d_failed = [];		// array of all failed
	
	private var f_progress; 		// callback on progress
	
	// store sync size
	private var d_todo = [];		// array of {:id => id, :type => type} objects
	private var d_todo_total;		// the number of items that had to be synced

	function initialize(progress, done, fail) {
		Deferrable.initialize(method(:sync), done, fail);		// make sync the deferred task
		
		f_progress = progress;
		
        d_provider.setFallback(method(:onError));
		d_provider.setProgressCallback(method(:onProgress));

		// first delete the todeletes
		var ids = ArtworkStore.getDeletes();
		for (var idx = 0; idx < ids.size(); ++idx) {
			var id = ids[idx];
			var artwork = new Artwork(ArtworkStore.get(id));
			var iartwork = new IArtwork(artwork.art_id(), artwork.type());
			iartwork.remove();				// remove from Storage
		}

		// now get the todos
		// ids = ArtworkStore.getIds();
		// for (var idx = 0; idx != ids.size(); ++idx) {
		// 	var artwork = new Artwork(ids[idx]);

		// 	// only add to todo if not yet stored
		// 	if (artwork.image() == null) {
		// 		d_todo.add(artwork);
		// 	}
		// }
		d_todo = ArtworkStore.getAll({:condition => method(:unstored)});
		d_todo_total = d_todo.size();
	}

	function unstored(artwork) {
		return (artwork.image() == null);
	}
	
	function sync() {
		// if songs all finished, complete this task
		if (d_todo.size() == 0) {
	   		return Deferrable.complete();				// set complete
		}

		// update progress
		f_progress.invoke(progress());
		
		// start download
		d_provider.getArtwork(d_todo[0].art_id(), d_todo[0].type(), method(:onDownloaded));
		return Deferrable.defer();
	}

	function progress() {
		// determine what is left to do
		var todo = 0;
		if (d_todo != null) { todo = d_todo.size(); }
		
		// determine what is done 
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
	function onDownloaded(artwork) {
		// update artwork
		d_todo[0].setImage(artwork);

		// continue to next song
		d_todo.removeAll(d_todo[0]);
	
		sync();
	}
    
    function onError(error) {
    	System.println("ArtworkSync::onError(" + error.shortString() + " : " + error.toString() + ")");

    	// indicate failed sync
//   	d_playlist.setError(error); TODO
    	// d_failed.add(d_todo[0]);
    	
    	// check if song in progress
		if ((d_todo.size() == 0)
			|| (d_todo[0] == null)) {
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