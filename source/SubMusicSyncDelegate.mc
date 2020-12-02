using Toybox.Application;
using Toybox.Communications;
using Toybox.Media;
using Toybox.Time;

// Performs the sync with the music provider
class SubMusicSyncDelegate extends Media.SyncDelegate {

    // playlists to sync
    private var d_todo;				// array of playlist ids
    private var d_todo_total = 0;
    
    private var d_loop;				// store deferred for loop

    // api access
    private var d_provider = SubMusic.Provider.get();

    // Constructor
    function initialize() {
        SyncDelegate.initialize();
    }

    // Starts the sync with the system
    function onStartSync() {
        System.println("Sync started...");

		// show progress
		Media.notifySyncProgress(0);
		
		// starting sync
        d_todo = PlaylistStore.getIds();
        d_todo_total = d_todo.size();
        
        // start async loop, provide callback to onLoopCompleted
        d_loop = new DeferredFor(0, d_todo.size(), self.method(:step), self.method(:onComplete));
        d_loop.run();
    }
    
    function onComplete() {
    	// finalize removals (deletes are deferred, to prevent redownloading)
		var todelete = SongStore.getDeletes();
		for (var idx = 0; idx < todelete.size(); ++idx) {
			var id = todelete[idx];
			var isong = new ISong(id);
			isong.setRefId(null);			// delete from cache
			isong.remove();					// remove from Store
		}

    	System.println("Sync completed...");

		// finish sync
		Media.notifySyncComplete(null);
		Communications.notifySyncComplete(null);
		return;
	}
	
	function onProgress(progress) {
		System.println("Sync Progress: list " + (d_loop.idx() + 1) + " of " + d_loop.end() + " is on " + progress + " %");

		progress += (100 * d_loop.idx());
		progress /= d_loop.end().toFloat();
		
		System.println(progress.toNumber());
		Media.notifySyncProgress(progress.toNumber());
	}
    
    function step(idx) {
    	return new PlaylistSync(d_provider, d_todo[idx], method(:onProgress));
    }

    // Sync always needed to verify new songs on the server
    function isSyncNeeded() {
        return true;
    }
}
