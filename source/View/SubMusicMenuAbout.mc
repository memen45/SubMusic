using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class About extends MenuBase {

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.About_label), false);
			}

			function load() {
				System.println("Menu.About::load()");
				return MenuBase.load([
					{
						LABEL => WatchUi.loadResource(Rez.Strings.AppName) + " " + WatchUi.loadResource(Rez.Strings.Version_label), 
						SUBLABEL => (new SubMusicVersion(null)).toString(), 
						METHOD => "version",		// not used, null does not work
					},
					new Menu.AboutSettings(),
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