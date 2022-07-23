using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;
using Toybox.Media;

module SubMusic {
	module Menu {
		class AboutSettings extends MenuBase {

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.Settings_label), false);
			}

			function load() {
				System.println("Menu.AboutSettings::load()");
				return MenuBase.load([
					{
						LABEL => WatchUi.loadResource(Rez.Strings.ApiStandard),
						SUBLABEL => method(:sublabel_API_standard),
						METHOD => "API_standard"
					},
					{
						LABEL => WatchUi.loadResource(Rez.Strings.ServerAddress),
						SUBLABEL => Application.Properties.getValue("subsonic_API_URL"),
						METHOD => "subsonic_API_URL"
					},
					{
						LABEL => WatchUi.loadResource(Rez.Strings.ServerUser),
						SUBLABEL => Application.Properties.getValue("subsonic_API_usr"),
						METHOD => "subsonic_API_usr"
					},
					// POTENTIAL PASSWORD EXPOSURE, KEEP DISABLED
					// {
					// 	LABEL => WatchUi.loadResource(Rez.Strings.ServerKey),
					// 	SUBLABEL => Application.Properties.getValue("subsonic_API_key"),
					// 	METHOD => "subsonic_API_key"
					// },
					{
						LABEL => WatchUi.loadResource(Rez.Strings.ApiAuthMethod),
						SUBLABEL => method(:sublabel_AUTH_method),
						METHOD => "subsonic_AUTH_method"
					},
					{
						LABEL => WatchUi.loadResource(Rez.Strings.skip_30s),
						SUBLABEL => WatchUi.loadResource(Rez.Strings.skip_30s_sublabel),
						METHOD => method(:onToggle),
						OPTION => Application.Properties.getValue("skip_30s"),
					},
					{
						LABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_RemoveAll_label), 
						SUBLABEL => WatchUi.loadResource(Rez.Strings.confSync_MoreInfo_RemoveAll_sublabel),
						METHOD => method(:onRemoveAll),
					},
				]);
			}

			function onDetail(item as WatchUi.MenuItem) {
				WatchUi.pushView(new TextView(item.getSubLabel()), null, WatchUi.SLIDE_IMMEDIATE);
			}

			function sublabel_API_standard() {
				var api_typ = Application.Properties.getValue("API_standard");
				if (api_typ == ApiStandard.AMPACHE) {
	        		return WatchUi.loadResource(Rez.Strings.ApiStandardAmpache);
				}
	        	return WatchUi.loadResource(Rez.Strings.ApiStandardSubsonic);
			}

			function sublabel_AUTH_method() {
				var api_aut = Application.Properties.getValue("subsonic_AUTH_method");
				if (api_aut == ApiAuthMethod.API_AUTH) {
					return WatchUi.loadResource(Rez.Strings.ApiAuthAPI);
				}
				return WatchUi.loadResource(Rez.Strings.ApiAuthHTTP);
			}

			function onToggle() {
				Application.Properties.setValue("skip_30s", !Application.Properties.getValue("skip_30s"));
			}

			function delegate() {
				return new MenuDelegate(method(:onDetail), null);
			}
			
			static function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
			
			static function onRemoveAll() {
				var msg = "Are you sure you want to delete all Application data?";
				WatchUi.pushView(new WatchUi.Confirmation(msg), new SubMusicConfirmationDelegate(self.method(:removeAll)), WatchUi.SLIDE_IMMEDIATE);
			}
			
			static function removeAll() {
				System.println("Settings::removeAll()");
				// collect all ids of songs
				// var ids = SongStore.getIds();
				// for (var idx = 0; idx != ids.size(); ++idx) {
				// 	var id = ids[idx];
				// 	var isong = new ISong(id);
				// 	isong.remove();					// remove from Store
				// }
				// ids = EpisodeStore.getIds();
				// for (var idx = 0; idx != ids.size(); ++idx) {
				// 	var id = ids[idx];
				// 	var iepisode = new IEpisode(id);
				// 	iepisode.remove();					// remove from Store
				// }
				// ids = ArtworkStore.getIds();
				// for (var idx = 0; idx < ids.size(); ++idx) {
				// 	var id = ids[idx];
				// 	var iartwork = new IArtwork(id);
				// 	iartwork.remove();				// remove from Storage
				// }

				// remove all cached media
				Media.resetContentCache();
				
				// remove all metadata
				Application.Storage.clearValues();
				
				// check storage to set the storage version number
				Storage.check();

				// exit app to make sure ram is cleared
				System.exit();
			}
		}
	}
}