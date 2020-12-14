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
			
			function getItems() {
				return {
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
				WatchUi.pushView(new SubMusicConfigureSyncPlaylistView(), null, WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onStartSync() {
				Communications.startSync();
			}
			
			function onMoreInfo() {
				WatchUi.pushView(new SubMusic.Menu.MoreView(), new SubMusic.Menu.Delegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
		
		class SyncView extends MenuView {
			function initialize() {
				MenuView.initialize(new Sync());
			}
		}
	}
}