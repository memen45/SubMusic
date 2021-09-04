using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;
using Toybox.Time;

module SubMusic {
	module Menu {
		class More extends MenuBase {

			hidden var d_items = [
				new Menu.PlaylistsRemoteToggle(WatchUi.loadResource(Rez.Strings.confSync_SelectPlaylists_label)),		// Temporarily here, future: use browse
				{
					LABEL => WatchUi.loadResource(Rez.Strings.confSync_StartSync_label), 
					SUBLABEL => method(:getLastSyncString), 
					METHOD => method(:onStartSync),
				},
				new Menu.Browse(),
				{
					LABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_TestServer_label), 
					SUBLABEL => null, 
					METHOD => method(:onTestServer),
				},
				{
					LABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_ServerDetail_label),
					SUBLABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_ServerDetail_sublabel),
					METHOD => method(:onServerDetail),
				},
				new Menu.About(),
				{
					LABEL => WatchUi.loadResource(Rez.Strings.Donate_label), 
					SUBLABEL => null, 
					METHOD => method(:onDonate),
				},
			];

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.More_label), true);
			}
			
			function getLastSyncString() {
				var lastsync = Application.Storage.getValue(Storage.LAST_SYNC);
		        var sublabel = null;
		        if ((lastsync != null) && (lastsync["time"] instanceof Lang.Number)) {
		        	var moment = new Time.Moment(lastsync["time"]);
			        var info = Time.Gregorian.info(moment, Time.FORMAT_MEDIUM);
			        sublabel = Lang.format("$1$ $2$ $3$ - $4$:$5$", [ info.day, info.month, info.year, info.hour, info.min.format("%02d") ]);
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
			
			function onTestServer() {
				WatchUi.pushView(new SubMusicTestView(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onServerDetail() {
				WatchUi.pushView(new SubMusicServerView(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}	
		}
	}
}