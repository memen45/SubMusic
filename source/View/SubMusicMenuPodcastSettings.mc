using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PodcastSettings extends MenuBase {

            private var d_id;
            private var d_podcast;

            hidden var d_items = [
                {
                    LABEL => WatchUi.loadResource(Rez.Strings.Menu_PlayNow_label),
                    SUBLABEL => null,
                    METHOD => method(:onPlay),
                },
            ];

            function initialize(podcast) {
                d_podcast = podcast;
                d_id = podcast.id();

                // load podcast name from storage rather than online
                var ipodcast = new IPodcast(d_id);
                MenuBase.initialize(ipodcast.name(), true);

                d_items.add(new Menu.EpisodesLocal(
                    WatchUi.loadResource(Rez.Strings.Episodes_label),
                    d_podcast.episodes(),
                    method(:onEpisodeSelect)
                ));
            }

            function onPlay() {
                // start playback with podcast
                var iplayable = new SubMusic.IPlayable();
                iplayable.loadPodcast(d_id, null);
                Media.startPlayback(null);
            }

            function sublabel() {
                var ipodcast = new IPodcast(d_id);
                // var mins = (ipodcast.time() / 60).toNumber().toString();
                // var sublabel = mins + " mins";
                var sublabel = ipodcast.time();     // might be string hh:mm:ss
                if (!ipodcast.synced()) {
                    sublabel += " - needs sync";
                }
                return sublabel;
            }

            // provide custom handler for choosing an episode from the list
            function onEpisodeSelect(episodeid) {
                // start playback with podcast and episode combination
                var iplayable = new SubMusic.IPlayable();
                iplayable.loadPodcast(d_id, episodeid);
                Media.startPlayback(null);
            }
        }
    }
}