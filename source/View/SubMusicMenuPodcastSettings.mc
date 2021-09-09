using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PodcastSettings extends MenuBase {

            private var d_id;
            private var d_podcast;

            enum {
                PLAY,
                EPISODES,
                OFFLINE,
            }
            hidden var d_items = {
                PLAY => {
                    LABEL => WatchUi.loadResource(Rez.Strings.Menu_PlayNow_label),
                    SUBLABEL => null,
                    METHOD => method(:onPlay),
                },
                EPISODES => {},
                OFFLINE => {
                    LABEL => "Newest available offline",
                    SUBLABEL => null,
                    METHOD => OFFLINE,
                },
            };

            function initialize(podcast) {
                d_podcast = podcast;
                d_id = podcast.id();

                // load podcast name from storage rather than online
                var ipodcast = new IPodcast(d_id);
                MenuBase.initialize(ipodcast.name(), true);

                d_items.put(EPISODES, new Menu.EpisodesLocal(
                    WatchUi.loadResource(Rez.Strings.Episodes_label),
                    d_podcast.episodes(),
                    method(:onEpisodeSelect)
                ));
            }

            function getItem(idx) {

                // defer to base
                if (idx != OFFLINE) {
                    return MenuBase.getItem(idx);
                }
                
                // make toggle item for offline mode
                var item = d_items[idx];
                var ipodcast = new IPodcast(d_id);
                return new WatchUi.ToggleMenuItem(
                    item.get(LABEL),
                    item.get(SUBLABEL),
                    item.get(METHOD),
                    ipodcast.local(),
                    {}
                );
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

            function onOfflineToggle(item) {
                var ipodcast = new IPodcast(d_id);
                ipodcast.setLocal(item.isEnabled());
            }

            function delegate() {
                return new MenuDelegate(method(:onOfflineToggle), null);
            }
        }
    }
}