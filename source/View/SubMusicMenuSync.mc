using Toybox.WatchUi;
using Toybox.Time;

using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Sync extends MenuBase {
			
			enum {
				SELECT_PLAYLISTS,
				START_SYNC,
				MORE_INFO,
			}

			private var d_items = {
				SELECT_PLAYLISTS => {
					LABEL => WatchUi.loadResource(Rez.Strings.confSync_SelectPlaylists_label), 
					SUBLABEL => null, 
					METHOD => method(:onSelectPlaylists),
				},
				START_SYNC => {
					LABEL => WatchUi.loadResource(Rez.Strings.confSync_StartSync_label), 
					SUBLABEL => getLastSyncString(), 
					METHOD => method(:onStartSync),
				},
				MORE_INFO => {
					LABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_label), 
					SUBLABEL => null, 
					METHOD => method(:onMoreInfo),
				},
			};

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.confSync_Title), true);
			}
			
			// returns null if menu idx not found
			function getItem(idx) {

				// check if item exists
				var item = d_items.get(idx);
				if (item == null) {
					return null;
				}

				// update the sublabel
				if (idx == START_SYNC) {
					item[SUBLABEL] = getLastSyncString();
				}

				return new WatchUi.MenuItem(
					item[LABEL],		// label
					item[SUBLABEL],		// sublabel
					item[METHOD],		// identifier (use method for simple callback)
					null				// options
			    );
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
			
			function onSelectPlaylists() {
				// load the menu as it might be empty and or not ready
				var loader = new MenuLoader(
					new SubMusic.Menu.PlaylistsRemote(WatchUi.loadResource(Rez.Strings.confSync_Playlists_title)),
					new SubMusic.Menu.PlaylistsRemoteDelegate()
				);
			}
			
			function onStartSync() {
				// store sync request, refer to bug https://forums.garmin.com/developer/connect-iq/i/bug-reports/bug-media-communications-syncdelegate-blocks-charging
				Application.Storage.setValue(Storage.SYNC_REQUEST, true);
				var syncrequest  = Application.Storage.getValue(Storage.SYNC_REQUEST);
				System.println(syncrequest);
				
				// start the sync
				Communications.startSync();
			}
			
			function onMoreInfo() {
				WatchUi.pushView(
					new SubMusic.Menu.MoreView(),
					new SubMusic.Menu.MoreDelegate(),
					WatchUi.SLIDE_IMMEDIATE
				);
				// equivalent:
				// 
				// new MenuLoader(
				// 	new SubMusic.Menu.More(),
				// 	new SubMusic.Menu.MoreDelegate()
				// );
			}
		}
		
		class SyncView extends MenuView {
			function initialize() {
				MenuView.initialize(new Sync());
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