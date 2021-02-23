class ScrobbleSync extends Deferrable {
	
	private var d_provider;
	
	private var f_progress;
	
	private var d_scrobble = null;
	private var d_idx = 0;
	private var d_todo = ScrobbleStore.size();
	private var d_todo_total = ScrobbleStore.size();
	
	function initialize(provider, progress) {
		Deferrable.initialize(method(:sync));		// make sync the deferred task
		
		f_progress = progress;
		
		d_provider = provider;
        d_provider.setFallback(method(:onError));
   	}
   	
   	function sync() {
   		if (d_todo == 0) {
   			var complete = Deferrable.complete();
   			return complete;
   		}
   		
   		// update progress
   		f_progress.invoke(progress());
   		
   		// record first play on the list
   		var storage = ScrobbleStore.get(d_idx);
   		d_scrobble = new Scrobble(storage);
   		d_provider.recordPlay(d_scrobble.id(), d_scrobble.time(), method(:onRecordPlay));
   		return Deferrable.defer();
   	}
   	
   	function onRecordPlay(response) {
   		System.println("ScrobbleSync::onRecordPlay( response : " + response + ")");
   		
   		// decrement todos
   		d_todo -= 1;
   		
   		// remove front as it is done now
   		ScrobbleStore.remove(d_scrobble);
   		
   		// sync next
   		sync();
   	}
   	
   	function onError(error) {
   		System.println("ScrobbleSync::onError( " + error.shortString() + " " + error.toString() + ")");
   		
   		// some problem with the network - we can skip this and try again later
   		if ((error instanceof SubMusic.HttpError)
   			|| (error instanceof SubMusic.GarminSdkError)) {
   			
   			// to prevent unwanted OOM errors, better remove the scrobble
	   		onRecordPlay(null);
	   		
	   		// ideally, save scrobble and continue with next scrobble
	   		
	   		return;
	   	}
	   	
	   	// Nextcloud has 'missing method' and reports
	   	//
	   	// if ((error instanceof AmpacheError) 
	   	// 		&& (error.code() == AmpacheError.METHOD_MISSING))
	   	//
	   	// if ((error instanceof SubsonicError)
	   	//		&& (error.code() == SubsonicError.NOT_FOUND))
	   	//
	   	// perform default action
	   	
	   	// default action is to clear the list 
	   	
   		// remove all records, since it is not possible to store them anyways
   		ScrobbleStore.removeAll();
   		
   		// mark complete
   		Deferrable.complete();
   	}
   	
   	function progress() {
   		var done = d_todo_total - d_todo;
		var progress = (100 * done) / d_todo_total.toFloat();
		return progress;
   	}
}
   	