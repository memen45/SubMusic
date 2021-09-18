using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PlaylistSettings extends MenuBase {

            private var d_id;
            private var d_iplaylist;

            function initialize(iplaylist) {
                MenuBase.initialize(iplaylist.name(), false);

                d_iplaylist = iplaylist;
                d_id = iplaylist.id();
            }

            function load() {
                System.println("Menu.PlaylistSettings::load()");

                return MenuBase.load([
                    {
                        LABEL => WatchUi.loadResource(Rez.Strings.Menu_PlayNow_label),
                        SUBLABEL => null,
                        METHOD => method(:onPlay),
                    },
                    {
                        LABEL => WatchUi.loadResource(Rez.Strings.Menu_PlayShuffle_label),
                        SUBLABEL => null,
                        METHOD => method(:onShuffle),
                    },
                    {
                        LABEL => WatchUi.loadResource(Rez.Strings.Menu_PodcastMode_label),
                        SUBLABEL => WatchUi.loadResource(Rez.Strings.Menu_PodcastMode_sublabel),
                        METHOD => method(:onPodcastMode),
                        OPTION => method(:isPodcastMode),
                    },
                    new Menu.SongsLocal(
                        WatchUi.loadResource(Rez.Strings.Songs_label),
                        d_iplaylist.songs(),
                        method(:onSongSelect)
                    ),
                    {
                        LABEL => "Make available offline",
                        SUBLABEL => null,
                        METHOD => "offline",
                        OPTION => method(:isOffline),
                    },
                ]);
            }

            function isPodcastMode() {
                return d_iplaylist.podcast();
            }

            function isOffline() {
                return d_iplaylist.local();
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
                d_iplaylist.setPodcast(!d_iplaylist.podcast());     // flip podcast mode
            }

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

            function onOfflineToggle(item) {
                d_iplaylist.setLocal(item.isEnabled());
            }

            function delegate() {
                return new MenuDelegate(method(:onOfflineToggle), null);
            }
        }
    }
}