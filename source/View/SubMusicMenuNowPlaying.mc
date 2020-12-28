using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
	module Menu {
		class NowPlaying extends SongsLocal {

			function initialize() {
				SongsLocal.initialize(
					Rez.Strings.confPlayback_NowPlaying_title, 
					SubMusic.NowPlaying.getSongIds()
				);
			}
		}

		class NowPlayingView extends MenuView {
			function initialize() {
				MenuView.initialize(new NowPlaying());
			}
		}

        class NowPlayingDelegate extends MenuDelegate {
            function initialize() {
                MenuDelegate.initialize(method(:onSongSelect), null);
                // ids are ids, so have to be handled, no onBack action
            }

            function onSongSelect(item) {
                var id = item.getId();

                // store selection as current playlist
                SubMusic.NowPlaying.setSongId(id);

				// start the playback of this song
                Media.startPlayback(null);
            }
        }
	}
}