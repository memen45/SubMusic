using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Playback extends MenuBase {

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.confPlayback_Title), false);
			}

			function load() {
				System.println("Menu.Playback::load()");
				return MenuBase.load([
					new Menu.NowPlaying(),
					{
						LABEL => WatchUi.loadResource(Rez.Strings.confPlayback_PlayAll_label),
						SUBLABEL => null,
						METHOD => method(:onPlayAll),
					},
					new Menu.PlaylistsLocal(WatchUi.loadResource(Rez.Strings.playbackMenuTitle)),
					new Menu.PodcastsLocal(WatchUi.loadResource(Rez.Strings.Podcasts_label)),
					new Menu.More(),
					new Menu.About(),
					{
						LABEL => WatchUi.loadResource(Rez.Strings.Donate_label), 
						SUBLABEL => null, 
						METHOD => method(:onDonate),
					},
				]);
			}

			// plays all songs
			static function onPlayAll() {
				var iplayable = new SubMusic.IPlayable();
				iplayable.loadSongIds(SongStore.getIds());
				Media.startPlayback(null);
			}
			
			static function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
	}
}