using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;

module SubMusic {
	module Menu {
		class More extends MenuBase {			
			enum {
				TEST_SERVER,
				SERVER_DETAIL,
				DONATE,
				REMOVE_ALL,
				MANAGE_PLAYLISTS,
				PLAYLIST_DETAIL,
			}

			private var d_items = {
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

			function initialize() {
				MenuBase.initialize(Rez.Strings.confSync_MoreInfo_title, true);
			}

			// returns null if menu idx not found
			function getItem(idx) {

				// check if item exists
				var item = d_items.get(idx);
				if (item == null) {
					return null;
				}

				return new WatchUi.MenuItem(
					item[LABEL],		// label
					item[SUBLABEL],		// sublabel
					item[METHOD],		// identifier (use method for simple callback)
					null				// options
			    );
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

		class MoreDelegate extends MenuDelegate {
			function initialize() {
				MenuDelegate.initialize(null, null);
				// all ids are methods and no action on Back
			}
		}
	}
}