using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;

module SubMusic {
	module Menu {
		class More {
			var title = Rez.Strings.confSync_MoreInfo_title;
			
			enum {
				TEST_SERVER,
				SERVER_DETAIL,
				DONATE,
				REMOVE_ALL,
				MANAGE_PLAYLISTS,
				PLAYLIST_DETAIL,
			}
			var items = {
				TEST_SERVER => {
					LABEL => Rez.Strings.confSync_MoreInfo_TestServer_label, 
					SUBLABEL => null, 
					METHOD => method(:onTestServer),
				},
				SERVER_DETAIL => {
					LABEL => Rez.Strings.confSync_MoreInfo_ServerDetail_label,
					SUBLABEL => Rez.Strings.confSync_MoreInfo_ServerDetail_sublabel,
					METHOD => method(:onServerDetail),
				},
				DONATE => {
					LABEL => Rez.Strings.Donate_label, 
					SUBLABEL => null, 
					METHOD => method(:onDonate),
				},
				REMOVE_ALL => {
					LABEL => Rez.Strings.confSync_MoreInfo_RemoveAll_label, 
					SUBLABEL => Rez.Strings.confSync_MoreInfo_RemoveAll_sublabel,
					METHOD => method(:onRemoveAll),
				},
			};
			
			function onTestServer() {
				WatchUi.pushView(new SubMusicTestView(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onServerDetail() {
				WatchUi.pushView(new SubMusicServerView(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onRemoveAll() {
				var msg = "Are you sure you want to delete all Application data?";
				WatchUi.pushView(new WatchUi.Confirmation(msg), new SubMusicConfirmationDelegate(self.method(:removeAll)), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function removeAll() {
				// collect all ids of songs
				var ids = SongStore.getIds();
				for (var idx = 0; idx != ids.size(); ++idx) {
					var id = ids[idx];
					var isong = new ISong(id);
					isong.setRefId(null);			// delete from cache
					isong.remove();					// remove from Store
				}
				
				// remove all metadata
				Application.Storage.clearValues();
				
				// check storage to set the storage version number
				Storage.check();
			}
		}
		
		class MoreView extends MenuView {
			function initialize() {
				MenuView.initialize(new More());
			}
		}
	}
}