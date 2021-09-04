using Toybox.WatchUi;
using SubMusic.Menu;
using SubMusic;

module SubMusic {
	module Menu {
		class NowPlaying extends SongsLocal {

			function initialize() {
				var iplayable = new SubMusic.IPlayable();
				SongsLocal.initialize(
					WatchUi.loadResource(Rez.Strings.confPlayback_NowPlaying_title), 
					iplayable.getSongIds(),
					method(:onSongSelect)
				);
			}

			function onSongSelect(songid) {
				// start playback with new songid
				var iplayable = new SubMusic.IPlayable();
				iplayable.setSongId(songid);
				Media.startPlayback(null);
			}

			// function delegate() {
			// 	return new NowPlayingDelegate();
			// }
		}

		// class NowPlayingView extends MenuView {
		// 	function initialize() {
		// 		MenuView.initialize(new NowPlaying());
		// 	}
		// }

        // class NowPlayingDelegate extends SongsLocalDelegate {
		// 	function initialize() {
		// 		SongsLocalDelegate.initialize();
		// 	}

		// 	// @Override
		// 	function onSongSelect(item) {
		// 		var songid = item.getId();

		// 		// start playback with new songid
		// 		var iplayable = new SubMusic.IPlayable();
		// 		iplayable.setSongId(songid);
		// 		Media.startPlayback(null);
		// 	}
		// }
	}
}