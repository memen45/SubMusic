using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Application;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class About extends MenuBase {			
			// enum {
			// 	SETTINGS,
			// 	SUBMUSIC_VERSION,
			// 	DONATE,
			// }

			hidden var d_items = [
				{
					LABEL => WatchUi.loadResource(Rez.Strings.Version_label), 
					SUBLABEL => (new SubMusicVersion(null)).toString(), 
					METHOD => "version",		// not used, null does not work
				},
				new Menu.AboutSettings(),
				{
					LABEL => WatchUi.loadResource(Rez.Strings.Donate_label), 
					SUBLABEL => null, 
					METHOD => method(:onDonate),
				},
			];

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.About_label), true);
			}

			// returns null if menu idx not found
			// function getItem(idx) {

			// 	// check if item exists
			// 	var item = d_items.get(idx);
			// 	if (item == null) {
			// 		return null;
			// 	}

			// 	return new WatchUi.MenuItem(
			// 		item[LABEL],		// label
			// 		item[SUBLABEL],		// sublabel
			// 		item[METHOD],		// identifier (use method for simple callback)
			// 		null				// options
			//     );
			// }

			// function onSettings() {
			// 	WatchUi.pushView(new AboutSettingsView(), new AboutSettingsDelegate(), WatchUi.SLIDE_IMMEDIATE);
			// }
			
			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
		
		// class AboutView extends MenuView {
		// 	function initialize() {
		// 		MenuView.initialize(new About());
		// 	}
		// }

		// class AboutDelegate extends MenuDelegate {
		// 	function initialize() {
		// 		MenuDelegate.initialize(null, null);
		// 		// all ids are methods and no action on Back
		// 	}
		// }
	}
}