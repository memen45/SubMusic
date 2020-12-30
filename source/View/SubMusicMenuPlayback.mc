using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class Playback extends MenuBase {
			enum {
				NOW_PLAYING,
				SELECT_PLAYLIST,
				OPEN_SYNC,
				DONATE,
			}
			
			private var d_items = {
				NOW_PLAYING => { 
					LABEL => Rez.Strings.confPlayback_NowPlaying_label, 
					SUBLABEL => null, 
					METHOD => method(:onNowPlaying),
				},
				SELECT_PLAYLIST => { 
					LABEL => Rez.Strings.confPlayback_SelectPlaylist_label, 
					SUBLABEL => null, 
					METHOD => method(:onSelectPlaylist),
				},
				OPEN_SYNC => {
					LABEL => Rez.Strings.confPlayback_OpenSync_label, 
					SUBLABEL => null, 
					METHOD => method(:onOpenSync),
				},
				DONATE => {
					LABEL => Rez.Strings.Donate_label, 
					SUBLABEL => null, 
					METHOD => method(:onDonate),
				},
			};

			function initialize() {
				MenuBase.initialize(Rez.Strings.confPlayback_Title, true);
			}

			// returns null if menu idx not found
			function getItem(idx) {

				// check if item exists
				var item = d_items.get(idx);
				if (item == null) {
					return null;
				}

				return new WatchUi.MenuItem(
					item[LABEL],		// label
					item[SUBLABEL],		// sublabel
					item[METHOD],		// identifier (use method for simple callback)
					null				// options
			    );
			}

			function onNowPlaying() {
				// WatchUi.pushView(
				// 	new SubMusic.Menu.NowPlayingView(),
				// 	new SubMusic.Menu.NowPlayingDelegate(),
				// 	WatchUi.SLIDE_IMMEDIATE
				// );
				System.println("Playback::onNowPlaying");
				var loader = new MenuLoader(
					new SubMusic.Menu.NowPlaying(),
					new SubMusic.Menu.NowPlayingDelegate()
				);
			}
			
			function onSelectPlaylist() {
				WatchUi.pushView(
					new SubMusic.Menu.PlaylistsLocalView(Rez.Strings.playbackMenuTitle), 
					new SubMusic.Menu.PlaylistsLocalDelegate(), 
					WatchUi.SLIDE_IMMEDIATE
				);
				//WatchUi.pushView(new SubMusicConfigurePlaybackPlaylistView(), null, WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onOpenSync() {
				// nothing to do on menu exit, so null
				WatchUi.pushView(new SubMusic.Menu.SyncView(), new SubMusic.Menu.SyncDelegate(null), WatchUi.SLIDE_IMMEDIATE);
			}
			
			function onDonate() {
				WatchUi.pushView(new DonateView(), new DonateDelegate(), WatchUi.SLIDE_IMMEDIATE);
			}
		}
		
		class PlaybackView extends MenuView {
			function initialize() {
				MenuView.initialize(new Playback());
			}
		}

		class PlaybackDelegate extends MenuDelegate {
			function initialize() {
				MenuDelegate.initialize(null, null);
				// all ids are methods and no action on Back
			}
		}
	}
}