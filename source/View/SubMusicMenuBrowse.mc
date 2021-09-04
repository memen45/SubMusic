using Toybox.WatchUi;
using SubMusic.Menu;
using SubMusic;

module SubMusic {
	module Menu {
		class Browse extends MenuBase {

			hidden var d_items = [
				new Menu.PlaylistsRemote(WatchUi.loadResource(Rez.Strings.Playlists_label)),
				new Menu.PodcastsRemote(WatchUi.loadResource(Rez.Strings.Podcasts_label)),
				// new Menu.Radiostations(WatchUi.loadResource(Rez.Strings.Radiostations_label)),
				new Menu.About(),
				{
					LABEL => WatchUi.loadResource(Rez.Strings.Donate_label), 
					SUBLABEL => null, 
					METHOD => method(:onDonate),
				},
			];

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.Browse_label), true);
			}

			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
	}
}