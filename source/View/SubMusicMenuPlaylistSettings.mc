using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PlaylistSettings extends MenuBase {

            private var d_id;
            private var d_playlist;

            // keep enum, as PODCAST_MODE should have toggle
            enum {
                PLAY,
                SHUFFLE,
                PODCAST_MODE,
                SONGS,
            }
            hidden var d_items = {
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
                    METHOD => method(:onPodcastMode),
                },
                // // SONGS => {
                // //     LABEL => WatchUi.loadResource(Rez.Strings.Menu_Songs_label),
                // //     SUBLABEL => null,
                // //     METHOD => method(:onSongs),
                // // },
                SONGS => {},
            };

            function initialize(playlist) {
                d_playlist = playlist;
                d_id = playlist.id();

                // load playlist name from storage rather than online
                var iplaylist = new IPlaylist(d_id);
                MenuBase.initialize(iplaylist.name(), true);

                d_items[SONGS] = new Menu.SongsLocal(
                    WatchUi.loadResource(Rez.Strings.Songs_label),
                    d_playlist.songs(),
                    method(:onSongSelect)
                );
            }

            function getItem(idx) {

                // defer to base
                if (idx != PODCAST_MODE) {
                    return MenuBase.getItem(idx);
                }
                
                // make toggle item for podcast_mode
                var item = d_items.get(idx);
                var iplaylist = new IPlaylist(d_id);
                return new WatchUi.ToggleMenuItem(
                    item.get(LABEL),
                    item.get(SUBLABEL),
                    item.get(METHOD),
                    iplaylist.podcast(),
                    {}
                );
            }

            function onPlay() {
                // start playback with playlist
                var iplayable = new SubMusic.IPlayable();
                iplayable.loadPlaylist(d_id, null);
                Media.startPlayback(null);
            }

            function onShuffle() {
                // start playback with playlist in shuffle mode
                var iplayable = new SubMusic.IPlayable();
                iplayable.loadPlaylist(d_id, null);
                iplayable.shuffleIdcs(true);
                Media.startPlayback(null);
            }

            function onPodcastMode() {
                // iplaylist required to modify 
                var iplaylist = new IPlaylist(d_id);
                iplaylist.setPodcast(!iplaylist.podcast());     // flip podcast mode
            }

            // function onSongs() {
            //     var loader = new MenuLoader(
            //         new SubMusic.Menu.SongsLocal(WatchUi.loadResource(Rez.Strings.Menu_PlaylistSongs_title), d_iplaylist.songs()),
            //         new SubMusic.Menu.PlaylistSongsDelegate(d_id)
            //     );
            // }

            function sublabel() {
                var iplaylist = new IPlaylist(d_id);
                var mins = (iplaylist.time() / 60).toNumber().toString();
                var sublabel = mins + " mins";
                if (!iplaylist.synced()) {
                    sublabel += " - needs sync";
                }
                return sublabel;
            }

            // provide custom handler for choosing a song from the list
            function onSongSelect(songid) {
                // start playback with playlist and song combination
                var iplayable = new SubMusic.IPlayable();
                iplayable.loadPlaylist(d_id, songid);
                Media.startPlayback(null);
            }
        }

        // class PlaylistSongsDelegate extends SongsLocalDelegate {

        //     private var d_id;

        //     function initialize(id) {
        //         SongsLocalDelegate.initialize();

        //         d_id = id;
        //     }

        //     // @Override
        //     function onSongSelect(item) {
        //         var songid = item.getId();

        //         // start playback with playlist and song combination
        //         var iplayable = new SubMusic.IPlayable();
        //         iplayable.loadPlaylist(d_id, songid);
        //         Media.startPlayback(null);
        //     }
        // }
    }
}