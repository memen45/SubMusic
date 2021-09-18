using Toybox.WatchUi;
using SubMusic.Menu;
using SubMusic;

module SubMusic {
	module Menu {
		class Browse extends MenuBase {

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.Browse_label), false);
			}

			function load() {
				System.println("Menu.Browse::load()");
				return MenuBase.load([
					new Menu.PlaylistsRemote(WatchUi.loadResource(Rez.Strings.Playlists_label)),
					new Menu.PodcastsRemote(WatchUi.loadResource(Rez.Strings.Podcasts_label)),
					// new Menu.Radiostations(WatchUi.loadResource(Rez.Strings.Radiostations_label)),
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