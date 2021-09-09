using Toybox.WatchUi;
using Toybox.Time;

using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Sync extends MenuBase {
			
			hidden var d_items = [
				new Menu.PlaylistsRemoteToggle(WatchUi.loadResource(Rez.Strings.confSync_SelectPlaylists_label)),		// Temporarily here, future: use browse
				{
					LABEL => WatchUi.loadResource(Rez.Strings.confSync_StartSync_label), 
					SUBLABEL => method(:getLastSyncString), 
					METHOD => method(:onStartSync),
				},
				new Menu.Browse(),
				new Menu.About(),
			];

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.confSync_Title), true);
			}
			
			function getLastSyncString() {
				var lastsync = Application.Storage.getValue(Storage.LAST_SYNC);
		        var sublabel = null;
		        if ((lastsync != null) && (lastsync["time"] instanceof Lang.Number)) {
		        	var moment = new Time.Moment(lastsync["time"]);
			        var info = Time.Gregorian.info(moment, Time.FORMAT_MEDIUM);
			        sublabel = Lang.format("$1$ $2$ $3$ - $4$:$5$", [ info.day, info.month, info.year, info.hour, info.min ]);
	        	}
	        	return sublabel;
			}
			
			function onStartSync() {
				// store sync request, refer to bug https://forums.garmin.com/developer/connect-iq/i/bug-reports/bug-media-communications-syncdelegate-blocks-charging
				Application.Storage.setValue(Storage.SYNC_REQUEST, true);
				var syncrequest  = Application.Storage.getValue(Storage.SYNC_REQUEST);
				System.println(syncrequest);
				
				// start the sync
				Communications.startSync();
			}

			// 
			function delegate() {
				return new SyncDelegate(method(:onBack));
			}
			
    
			function onBack() {
				var msg = "Note: \"Start syncing music\" might not complete. Use Playback > More.";
				WatchUi.switchToView(new TextView(msg), new TapDelegate(method(:popView)), WatchUi.SLIDE_IMMEDIATE);
			}
		}

		class SyncDelegate extends MenuDelegate {
			function initialize(callOnBack) {
				MenuDelegate.initialize(null, callOnBack);
				// all ids are methods and action on Back is given
			}
		}
	}
}