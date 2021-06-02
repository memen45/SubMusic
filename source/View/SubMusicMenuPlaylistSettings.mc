using Toybox.WatchUi;

module SubMusic {
    module Menu {
        class PlaylistSettings extends MenuBase {

            private var d_id;
            private var d_iplaylist;

            enum {
                PLAY,
                SHUFFLE,
                PODCAST_MODE,
                SONGS,
            }
            private var d_items = {
                PLAY => {
                    LABEL => WatchUi.loadResource(Rez.Strings.Menu_PlayNow_label),
                    SUBLABEL => null,
                    METHOD => method(:onPlay),
                },
                SHUFFLE => {
                    LABEL => WatchUi.loadResource(Rez.Strings.Menu_PlayShuffle_label),
                    SUBLABEL => null,
                    METHOD => method(:onShuffle),
                },
                PODCAST_MODE => {
                    LABEL => WatchUi.loadResource(Rez.Strings.Menu_PodcastMode_label),
                    SUBLABEL => WatchUi.loadResource(Rez.Strings.Menu_PodcastMode_sublabel),
                    METHOD => method(:onPodcastMode)
                },
                SONGS => {
                    LABEL => WatchUi.loadResource(Rez.Strings.Menu_Songs_label),
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
            	SubMusic.NowPlaying.setPlayable(new PlaylistPlayable(d_id, null));
                Media.startPlayback(null);
            }

            function onShuffle() {
                // start playback with playlist 
                var playable = new PlaylistPlayable(d_id, null);
                playable.shuffleIdcs(true);
                SubMusic.NowPlaying.setPlayable(playable);
                Media.startPlayback(null);
            }

            function onPodcastMode() {
                d_iplaylist.setPodcast(!d_iplaylist.podcast());     // flip podcast mode
            }

            function onSongs() {
                var loader = new MenuLoader(
                    new SubMusic.Menu.SongsLocal(WatchUi.loadResource(Rez.Strings.Menu_PlaylistSongs_title), d_iplaylist.songs()),
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
                var songid = item.getId();

                // start playback with playlist and song combination
                SubMusic.NowPlaying.setPlayable(new PlaylistPlayable(d_id, songid));
                Media.startPlayback(null);
            }
        }
    }
}