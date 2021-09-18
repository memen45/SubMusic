using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PodcastSettingsRemote extends MenuBase {

            private var d_id;
            private var d_podcast;

            function initialize(podcast) {
                MenuBase.initialize(podcast.name(), false);

                d_podcast = podcast;
                d_id = podcast.id();
            }

            function load() {
                System.println("Menu.PodcastSettingsRemote::load()");

                return MenuBase.load([
                    {
                        LABEL => "Newest available offline",
                        SUBLABEL => null,
                        METHOD => "offline",
                        OPTION => method(:isOffline),
                    },
                    new Menu.EpisodesRemote(
                            WatchUi.loadResource(Rez.Strings.Episodes_label),
                            d_id
                        ),
                ]);
            }

            function isOffline() {
                var ipodcast = new IPodcast(d_id);
                return ipodcast.local();
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