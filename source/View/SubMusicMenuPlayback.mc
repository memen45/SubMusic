using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Playback extends MenuBase {
			// enum {
			// 	NOW_PLAYING,
			// 	PLAY_ALL,
			// 	PLAYLISTS,
			// 	PODCASTS,
			// 	MORE,
			// 	ABOUT,
			// 	DONATE,

			// }
			
			hidden var d_items = [
				// NOW_PLAYING => { 
				// 	LABEL => WatchUi.loadResource(Rez.Strings.confPlayback_NowPlaying_label), 
				// 	SUBLABEL => null, 
				// 	METHOD => method(:onNowPlaying),
				// },
				new Menu.NowPlaying(),
				{
					LABEL => WatchUi.loadResource(Rez.Strings.confPlayback_PlayAll_label),
					SUBLABEL => null,
					METHOD => method(:onPlayAll),
				},
				// PLAYLISTS => { 
				// 	LABEL => WatchUi.loadResource(Rez.Strings.confPlayback_SelectPlaylist_label), 
				// 	SUBLABEL => null, 
				// 	METHOD => method(:onSelectPlaylist),
				// },
				new Menu.PlaylistsLocal(WatchUi.loadResource(Rez.Strings.playbackMenuTitle)),
				// { 
				// 	LABEL => WatchUi.loadResource(Rez.Strings.confPlayback_SelectPodcast_label), 
				// 	SUBLABEL => null, 
				// 	METHOD => method(:onSelectPlaylist),
				// },
				new Menu.PodcastsLocal(WatchUi.loadResource(Rez.Strings.Podcasts_label)),
				// MORE => {
				// 	LABEL => WatchUi.loadResource(Rez.Strings.confPlayback_More_label), 
				// 	SUBLABEL => null, 
				// 	METHOD => method(:onMore),
				// },
				new Menu.More(),
				new Menu.About(),
				// ABOUT => {
				// 	LABEL => WatchUi.loadResource(Rez.Strings.About_label), 
				// 	SUBLABEL => null, 
				// 	METHOD => method(:onAbout),
				// },
				{
					LABEL => WatchUi.loadResource(Rez.Strings.Donate_label), 
					SUBLABEL => null, 
					METHOD => method(:onDonate),
				},
			];

			function initialize() {
				MenuBase.initialize(WatchUi.loadResource(Rez.Strings.confPlayback_Title), true);
			}

			// // returns null if menu idx not found
			// function getItem(idx) {

			// 	// check if item exists
			// 	var item = d_items.get(idx);
			// 	if (item == null) {
			// 		return null;
			// 	}

			// 	return new WatchUi.MenuItem(
			// 		item.get(LABEL),		// label
			// 		item.get(SUBLABEL),		// sublabel
			// 		item.get(METHOD),		// identifier (use method for simple callback)
			// 		null				// options
			//     );
			// }

			// function onNowPlaying() {
			// 	// WatchUi.pushView(
			// 	// 	new SubMusic.Menu.NowPlayingView(),
			// 	// 	new SubMusic.Menu.NowPlayingDelegate(),
			// 	// 	WatchUi.SLIDE_IMMEDIATE
			// 	// );
			// 	System.println("Playback::onNowPlaying");
			// 	var loader = new MenuLoader(
			// 		new SubMusic.Menu.NowPlaying(),
			// 		new SubMusic.Menu.NowPlayingDelegate()
			// 	);
			// }

			// plays all songs
			function onPlayAll() {
				var iplayable = new SubMusic.IPlayable();
				iplayable.loadSongIds(SongStore.getIds());
				Media.startPlayback(null);
			}
			
			// function onSelectPlaylist() {
			// 	var loader = new MenuLoader(
			// 		new SubMusic.Menu.PlaylistsLocal(WatchUi.loadResource(Rez.Strings.playbackMenuTitle)),
			// 		new SubMusic.Menu.PlaylistsLocalDelegate()
			// 	);
			// }
			
			// function onMore() {
			// 	WatchUi.pushView(new Menu.MoreView(), new Menu.MoreDelegate(), WatchUi.SLIDE_IMMEDIATE);
			// }

			// function onAbout() {
			// 	WatchUi.pushView(new Menu.AboutView(), new Menu.AboutDelegate(), WatchUi.SLIDE_IMMEDIATE);
			// }
			
			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
		
		// class PlaybackView extends MenuView {
		// 	function initialize() {
		// 		MenuView.initialize(new Playback());
		// 	}
		// }

		// class PlaybackDelegate extends MenuDelegate {
		// 	function initialize() {
		// 		MenuDelegate.initialize(null, null);
		// 		// all ids are methods and no action on Back
		// 	}
		// }
	}
}