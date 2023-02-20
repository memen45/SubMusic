using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Settings extends MenuBase {

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.Settings_label), false);
			}

			function load() {
				if ($.debug) {
					System.println("Menu.Settings::load()");
				}
				return MenuBase.load([
					new Menu.AppSettings(),
					new Menu.Storage(),
					{
						LABEL => WatchUi.loadResource(Rez.Strings.AppName) + " " + WatchUi.loadResource(Rez.Strings.Version_label), 
						SUBLABEL => (new SubMusicVersion(null)).toString(), 
						METHOD => "version",		// not used, null does not work
					},
					{
						LABEL => WatchUi.loadResource(Rez.Strings.Donate_label), 
						SUBLABEL => null, 
						METHOD => method(:onDonate),
					},
				]);
			}
			
			static function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
	}
}