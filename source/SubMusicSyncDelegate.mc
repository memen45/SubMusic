using Toybox.Application;
using Toybox.Communications;
using Toybox.Media;
using Toybox.Time;
using Toybox.WatchUi;

module SubMusic {
	
	// Performs the sync with the music provider
	class Syncer {

		// progress callbacks are variable due to Media/Communications bug
		private var d_notifySyncProgress;
		private var d_notifySyncComplete;

		// playlists to sync
		private var d_todo;				// array of playlist ids
		private var d_todo_total = 0;
		
		private var d_loop;				// store deferred for loop

		// api access
		private var d_provider = SubMusic.Provider.get();


		function initialize(notifySyncProgress, notifySyncComplete) {
			d_notifySyncProgress = notifySyncProgress;
			d_notifySyncComplete = notifySyncComplete;
		}

		// Starts the sync with the system
		function onStartSync() {
			System.println("Sync started...");

			// show progress
			d_notifySyncProgress.invoke(0);
			
			// first sync is on Scrobbles
			startScrobbleSync();
		}

		// stops the sync
		function onStopSync() {
			Communications.cancelAllRequests();

			var errorMessage = "Sync stopped";
			d_notifySyncComplete.invoke(errorMessage);
		}

		function startScrobbleSync() {
			var deferrable = new ScrobbleSync(d_provider, method(:onScrobbleProgress));
			deferrable.setCallback(method(:startPlaylistSync));
			if (deferrable.run()) {
				startPlaylistSync();		// continue with playlist sync afterwards
			}
			// not completed, so wait for callback
		}
	
		function onScrobbleProgress(progress) {
			System.println("Sync Progress: scrobble is on " + progress + " %");
			
			progress /= 2;
			
			System.println(progress.toNumber());
			d_notifySyncProgress.invoke(progress.toNumber());
		}

		function startPlaylistSync() {
			// starting sync
			d_todo = PlaylistStore.getIds();
			d_todo_total = d_todo.size();
			
			// start async loop, provide callback to onLoopCompleted
			d_loop = new DeferredFor(0, d_todo.size(), self.method(:stepPlaylist), self.method(:onPlaylistsDone), self.method(:onError));
			d_loop.run();
		}
		
		function stepPlaylist(idx) {
			return new PlaylistSync(d_provider, d_todo[idx], method(:onPlaylistProgress));
		}
		
		function onPlaylistsDone() {
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
			d_notifySyncComplete.invoke(null);
			Application.Storage.setValue(Storage.LAST_SYNC, { "time" => Time.now().value(), });
		}
		
		function onPlaylistProgress(progress) {
			// System.println("Sync Progress: list " + (d_loop.idx() + 1) + " of " + d_loop.end() + " is on " + progress + " %");

			progress += (100 * d_loop.idx());
			progress /= d_loop.end().toFloat();
			
			progress /= 2;
			progress += 50;		// add 50% done as that was the scrobble part
			
			// System.println(progress.toNumber());
			d_notifySyncProgress.invoke(progress.toNumber());
		}
		
		function onError(error) {
			System.println("SubMusicSyncDelegate::onError( " + error.shortString() + " " + error.toString() + ")");
			
			// notify short error during sync
			d_notifySyncComplete.invoke(error.shortString());
		}

		// Sync always needed to verify new songs on the server
		function isSyncNeeded() {
			return true;
		}
	}

	class SyncDelegate extends Communications.SyncDelegate {

		// store generic syncer for future calls
		private var d_syncer = new Syncer(
									method(:notifySyncProgress), 
									method(:notifySyncComplete));

		function initialize() {
			SyncDelegate.initialize();
		}

		function notifySyncProgres(percentageComplete) {
			Communications.notifySyncProgress(percentageComplete);
		}

		function notifySyncComplete(errorMessage) {
			System.println("SyncDelegate::notifySyncComplete()");
			Communications.notifySyncComplete(errorMessage);
			
			// mark as no sync request pending
        	Application.Storage.setValue(Storage.SYNC_REQUEST, false);
		}

		function isSyncNeeded() {
			return d_syncer.isSyncNeeded();
		}

		function onStartSync() {
			System.println("SyncDelegate::onStartSync()");
			return d_syncer.onStartSync();
		}

		function onStopSync() {
			System.println("SyncDelegate::onStopSync()");
			return d_syncer.onStopSync();
		}
	}

	class SyncDelegate_deprecated extends Media.SyncDelegate {

		private var d_syncer = new Syncer(
									method(:notifySyncProgress), 
									method(:notifySyncComplete));
		
		function initialize() {
			SyncDelegate.initialize();
		}

		function notifySyncProgres(percentageComplete) {
			Media.notifySyncProgress(percentageComplete);
		}

		function notifySyncComplete(errorMessage) {
			System.println("SyncDelegate_deprecated::notifySyncComplete()");
			Media.notifySyncComplete(errorMessage);
		}

		function isSyncNeeded() {
			return d_syncer.isSyncNeeded();
		}

		function onStartSync() {
			System.println("SyncDelegate_deprecated::onStartSync()");
			return d_syncer.onStartSync();
		}

		function onStopSync() {
			System.println("SyncDelegate_deprecated::onStopSync()");
			return d_syncer.onStopSync();
		}
	}
}
