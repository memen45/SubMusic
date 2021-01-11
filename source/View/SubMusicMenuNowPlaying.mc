using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class NowPlaying extends SongsLocal {

			function initialize() {
				SongsLocal.initialize(
					Rez.Strings.confPlayback_NowPlaying_title, 
					SubMusic.NowPlaying.getPlayable().getSongIds()
				);
			}
		}

		class NowPlayingView extends MenuView {
			function initialize() {
				MenuView.initialize(new NowPlaying());
			}
		}

        class NowPlayingDelegate extends SongsLocalDelegate {
			function initialize() {
				SongsLocalDelegate.initialize();
			}
		}
	}
}