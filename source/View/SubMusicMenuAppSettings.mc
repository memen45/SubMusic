using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;
using Toybox.Media;
using SubMusic.Storage;

module SubMusic {
	module Menu {
		class AppSettings extends MenuBase {

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.AppSettings_label), false);
			}

			function load() {
				if ($.debug) {
					System.println("Menu.AppSettings::load()");
				}
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
						METHOD => method(:onToggleSkip30s),
						OPTION => method(:stateSkip30s),
					},
					{
						LABEL => WatchUi.loadResource(Rez.Strings.debug),
						SUBLABEL => WatchUi.loadResource(Rez.Strings.debug_sublabel),
						METHOD => method(:onToggleDebug),
						OPTION => method(:stateDebug),
					},
				]);
			}

			function onDetail(item as WatchUi.MenuItem) {
				WatchUi.pushView(new TextView(item.getSubLabel()), null, WatchUi.SLIDE_IMMEDIATE);
			}

			function sublabel_API_standard() {
				var api_typ = Application.Properties.getValue("API_standard");
				var api_map = {
					Storage.ApiStandard.AMPACHE 	=> WatchUi.loadResource(Rez.Strings.ApiStandardAmpache),
					Storage.ApiStandard.SUBSONIC 	=> WatchUi.loadResource(Rez.Strings.ApiStandardSubsonic),
					Storage.ApiStandard.PLEX 		=> WatchUi.loadResource(Rez.Strings.ApiStandardPlex),
				};
				return api_map[api_typ];
			}

			function sublabel_AUTH_method() {
				var api_aut = Application.Properties.getValue("subsonic_AUTH_method");
				if (api_aut == Storage.ApiAuthMethod.API_AUTH) {
					return WatchUi.loadResource(Rez.Strings.ApiAuthAPI);
				}
				return WatchUi.loadResource(Rez.Strings.ApiAuthHTTP);
			}

			function stateSkip30s() {
				return Application.Properties.getValue("skip_30s");
			}

			function onToggleSkip30s() {
				var skip30s_new = !Application.Properties.getValue("skip_30s");
				if ($.debug) {
					System.println("Setting skip_30s from " + Application.Properties.getValue("skip_30s") + " to " + skip30s_new);
				}

				Application.Properties.setValue("skip_30s", !Application.Properties.getValue("skip_30s"));
				Media.requestPlaybackProfileUpdate();
			}

			function stateDebug() {
				return Application.Properties.getValue("debug");
			}

			function onToggleDebug() {
				var debug_new = !Application.Properties.getValue("debug");
				if ($.debug) {
					System.println("Setting debug from " + Application.Properties.getValue("debug") + " to " + debug_new);
				}

				Application.Properties.setValue("debug", debug_new);
				$.debug = debug_new;	// update the global debug flag
			}

			function delegate() {
				return new MenuDelegate(method(:onDetail), null);
			}
			
			static function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
	}
}