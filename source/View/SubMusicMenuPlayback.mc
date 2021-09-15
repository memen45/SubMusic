using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Playback extends MenuBase {
			
			hidden var d_items = [
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
			];

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.confPlayback_Title), true);
			}

			// plays all songs
			function onPlayAll() {
				var iplayable = new SubMusic.IPlayable();
				iplayable.loadSongIds(SongStore.getIds());
				Media.startPlayback(null);
			}
			
			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
	}
}