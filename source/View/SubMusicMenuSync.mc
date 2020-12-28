using Toybox.WatchUi;
using Toybox.Time;

using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Sync {
			var title = Rez.Strings.confSync_Title;
			
			enum {
				SELECT_PLAYLISTS,
				START_SYNC,
				MORE_INFO,
			}

			private var d_items = {
				SELECT_PLAYLISTS => {
					LABEL => Rez.Strings.confSync_SelectPlaylists_label, 
					SUBLABEL => null, 
					METHOD => method(:onSelectPlaylists),
				},
				START_SYNC => {
					LABEL => Rez.Strings.confSync_StartSync_label, 
					SUBLABEL => getLastSyncString(), 
					METHOD => method(:onStartSync),
				},
				MORE_INFO => {
					LABEL => Rez.Strings.confSync_MoreInfo_label, 
					SUBLABEL => null, 
					METHOD => method(:onMoreInfo),
				},
			};
			
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

			function loaded() {
				return true;
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
				WatchUi.pushView(
					new SubMusic.Menu.PlaylistsRemoteView(Rez.Strings.confSync_Playlists_title),
					new SubMusic.Menu.PlaylistsRemoteDelegate(),
					WatchUi.SLIDE_IMMEDIATE
				);
				// WatchUi.pushView(new SubMusicConfigureSyncPlaylistView(), null, WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onStartSync() {
				Communications.startSync();
			}
			
			function onMoreInfo() {
				WatchUi.pushView(new SubMusic.Menu.MoreView(), new SubMusic.Menu.MoreDelegate(), WatchUi.SLIDE_IMMEDIATE);
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