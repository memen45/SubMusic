using Toybox.WatchUi;

module SubMusic {
    module Menu {
        class PlaylistSettings extends MenuBase {

            private var d_id;
            private var d_iplaylist;

            enum {
                PLAY,
                PODCAST_MODE,
                SONGS,
            }
            private var d_items = {
                PLAY => {
                    LABEL => Rez.Strings.Menu_PlayNow_label,
                    SUBLABEL => null,
                    METHOD => method(:onPlay),
                },
                PODCAST_MODE => {
                    LABEL => Rez.Strings.Menu_PodcastMode_label,
                    SUBLABEL => null,
                    METHOD => method(:onPodcastMode)
                },
                SONGS => {
                    LABEL => Rez.Strings.Menu_Songs_label,
                    SUBLABEL => null,
                    METHOD => method(:onSongs),
                },
            };

            function initialize(id) {
                d_id = id;
                d_iplaylist = new IPlaylist(d_id);

                MenuBase.initialize(d_iplaylist.name(), true);
            }

            function getItem(idx) {

                // check if item exists
				var item = d_items.get(idx);
				if (item == null) {
					return null;
				}

                if (idx == PODCAST_MODE) {
                    return new WatchUi.ToggleMenuItem(
                        item[LABEL],
                        item[SUBLABEL],
                        item[METHOD],
                        d_iplaylist.podcast(),
                        {}
                    );
                }

				return new WatchUi.MenuItem(
					item[LABEL],		// label
					item[SUBLABEL],		// sublabel
					item[METHOD],		// identifier (use method for simple callback)
					null				// options
			    );
            }

            function onPlay() {
                SubMusic.NowPlaying.setPlaylistId(d_id);
                Media.startPlayback(null);
            }

            function onPodcastMode() {
                var iplaylist = new IPlaylist(d_id);
                iplaylist.setPodcast(!iplaylist.podcast());     // flip podcast mode
            }

            function onSongs() {
                var loader = new MenuLoader(
                    new SubMusic.Menu.SongsLocal(Rez.Strings.Menu_PlaylistSongs_title, d_iplaylist.songs()),
                    new SubMusic.Menu.PlaylistSongsDelegate(d_id)
                );
            }
        }

        class PlaylistSettingsDelegate extends MenuDelegate {
            function initialize() {
                MenuDelegate.initialize(null, null);
            }
        }

        class PlaylistSongsDelegate extends SongsLocalDelegate {

            private var d_id;

            function initialize(id) {
                SongsLocalDelegate.initialize();

                d_id = id;
            }

            // @Override
            function onSongSelect(item) {
                // set playlist 
                SubMusic.NowPlaying.setPlaylistId(d_id);

                // perform default action
                SongsLocalDelegate.onSongSelect(item);
            }
        }
    }
}