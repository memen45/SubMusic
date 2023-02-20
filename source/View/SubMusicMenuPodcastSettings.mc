using Toybox.WatchUi;
using SubMusic;

module SubMusic {
    module Menu {
        class PodcastSettings extends MenuBase {

            private var d_id;
            private var d_ipodcast;

            function initialize(ipodcast) {
                MenuBase.initialize(ipodcast.name(), false);

                d_ipodcast = ipodcast;
                d_id = ipodcast.id();
            }

            function load() {
                if ($.debug) {
                	System.println("Menu.PodcastSettings::load()");
                }

                return MenuBase.load([
                    {
                        LABEL => WatchUi.loadResource(Rez.Strings.Menu_PlayNow_label),
                        SUBLABEL => null,
                        METHOD => method(:onPlay),
                        // OPTION => d_ipodcast.artwork(),     // try and add artwork
                    },
                    new Menu.EpisodesLocal(
                            Rez.Strings.Episodes_label,
                            d_ipodcast.episodes(),
                            method(:onEpisodeSelect)
                        ),
                    {
                        LABEL => "Newest available offline",
                        SUBLABEL => null,
                        METHOD => "offline",
                        OPTION => method(:isOffline),
                    },
                ]);
            }

            function isOffline() {
                return d_ipodcast.local();
            }

            function onPlay() {
                // start playback with podcast
                var iplayable = new SubMusic.IPlayable();
                iplayable.loadPodcast(d_id, null);
                Media.startPlayback(null);
            }

            function sublabel() {
                // var mins = (ipodcast.time() / 60).toNumber().toString();
                // var sublabel = mins + " mins";
                var sublabel = d_ipodcast.time().toString();     // might be string hh:mm:ss
                if (sublabel == null) {
                    sublabel = "";
                }
                if (!d_ipodcast.synced()) {
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
                d_ipodcast.setLocal(item.isEnabled());
            }

            function delegate() {
                return new MenuDelegate(method(:onOfflineToggle), null);
            }
        }
    }
}