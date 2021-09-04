using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PodcastSettingsRemote extends MenuBase {

            private var d_id;
            private var d_podcast;
            
            enum {
                OFFLINE,
                EPISODES,
            }
            hidden var d_items = {
                OFFLINE => {
                    LABEL => "Newest available offline",
                    SUBLABEL => null,
                    METHOD => OFFLINE,
                },
                EPISODES => {},
            };

            function initialize(podcast) {
                d_podcast = podcast;
                d_id = podcast.id();

                // this class could become lazy loaded as well, e.g. for loading podcast details
                MenuBase.initialize(d_podcast.name(), true);

                d_items[EPISODES] = new Menu.EpisodesRemote(
                    WatchUi.loadResource(Rez.Strings.Episodes_label),
                    d_id
                );
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

            function sublabel() {
                var ipodcast = new IPodcast(d_id);
                if (ipodcast.local() && ipodcast.synced()) {
                    return "Local - synced";
                }
                if (ipodcast.local()) {
                    return "Local - needs sync";
                }
                return null;
            }

            function onOfflineToggle(item) {
                var ipodcast = new IPodcast(d_id);
                ipodcast.setLocal(item.isEnabled());
                if (item.isEnabled()) { ipodcast.updateMeta(d_podcast); }
            }

            function delegate() {
                return new MenuDelegate(method(:onOfflineToggle), null);
            }
        }
    }
}