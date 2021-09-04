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

		// playlists/podcasts to sync
		private var d_ids;				// array of playlist/podcast ids
		private var d_ids_total = 0;	// nr of ids in beginning
		private var d_last = 0;			// last idx

		enum { START, SCROBBLE = START, PLAYLISTS, PODCASTS, AUDIO, ARTWORK, END}
		private var d_syncstage = START;	// track the stage for sync process

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
			doSync();
		}

		// stops the sync
		function onStopSync() {
			Communications.cancelAllRequests();

			var errorMessage = "Sync stopped";
			d_notifySyncComplete.invoke(errorMessage);
		}

		function onCompleteSync() {
			System.println("Sync completed...");

			// finish sync
			d_notifySyncComplete.invoke(null);
			Application.Storage.setValue(Storage.LAST_SYNC, { "time" => Time.now().value(), });
		}

		function doSync() {
			var deferrable = getSync(d_syncstage);
			if (deferrable == null) {
				// this means no more syncs available
				onCompleteSync();
				return;
			}
			if (deferrable.run()) {
				onDone();
			}
			// if not completed, do nothing and wait for calback
		}

		function getSync(idx) {
			var progress = method(:onProgress);
			var done = method(:onDone);
			var fail = method(:onError);
			if (idx == SCROBBLE) {
				return new ScrobbleSync(progress, done, fail);
			} else if (idx == PLAYLISTS) {
				d_ids = PlaylistStore.getIds();
				var step = method(:stepPlaylist);
				return new DeferredFor(0, d_ids.size(), step, done, fail);
			} else if (idx == PODCASTS) {
				d_ids = PodcastStore.getIds();
				var step = method(:stepPodcast);
				return new DeferredFor(0, d_ids.size(), step, done, fail);
			} else if (idx == AUDIO) {
				return new AudioSync(progress, done, fail);
			} else if (idx == ARTWORK) {
				return new ArtworkSync(progress, done, fail);
			}
			return null;
		}

		function onDone() {
			// go to next stage
			d_syncstage += 1;
			doSync();
		}
	
		function onScrobbleProgress(progress) {
			System.println("Sync Progress: scrobble is on " + progress + " %");
			
			progress /= 2;
			
			System.println(progress.toNumber());
			d_notifySyncProgress.invoke(progress.toNumber());
		}
		
		function stepPlaylist(idx, done, fail) {
			d_last = idx;
			return new PlaylistSync(d_ids[idx], method(:onPlaylistProgress), done, fail);
		}
		
		function stepPodcast(idx, done, fail) {
			d_last = idx;
			return new PodcastSync(d_ids[idx], method(:onPodcastProgress), done, fail);
		}

		function onProgress(progress) {
			d_notifySyncProgress.invoke(progress.toNumber());
		}
		
		function onPlaylistProgress(progress) {
			// System.println("Sync Progress: list " + (d_loop.idx() + 1) + " of " + d_loop.end() + " is on " + progress + " %");

			// progress += (100 * d_last);
			// progress /= d_ids_total.toFloat();
			
			// progress /= 2;
			// progress += 50;		// add 50% done as that was the scrobble part
			
			// System.println(progress.toNumber());
			d_notifySyncProgress.invoke(progress.toNumber());
		}
		
		function onPodcastProgress(progress) {
			// System.println("Sync Progress: list " + (d_loop.idx() + 1) + " of " + d_loop.end() + " is on " + progress + " %");

			// progress += (100 * d_last);
			// progress /= d_ids_total.toFloat();
			
			// progress /= 2;
			// progress += 50;		// add 50% done as that was the scrobble part
			
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
