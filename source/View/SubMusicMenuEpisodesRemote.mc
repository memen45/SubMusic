using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class EpisodesRemote extends MenuBase {

            // menu items will be loaded in here 
            hidden var d_items = [];

            private var d_loading = false;
	        private var d_provider = SubMusic.Provider.get();
            private var d_id;       // store id of podcast channel

            function initialize(title, id) {
                // initialize base as not loaded
                MenuBase.initialize(title, false);

                d_provider.setFallback(method(:onError));
                d_id = id;

                // items should be lazy loaded by a menu loader
                // this prevents multiple concurrent requests
            }

            function load() {

                // if already loading, do nothing, wait for response
                if (d_loading) {
                    return;
                }

                // start loading
                d_loading = true;
                d_provider.getEpisodes(d_id, [0, 15], method(:onGetEpisodes));
            }

            function onGetEpisodes(episodes) {

                // store in class
                d_items = [];
                for (var idx = 0; idx != episodes.size(); ++idx) {
                    //d_items.add(new Menu.EpisodeSettingsRemote(episodes[idx]));
                    d_items.add({
                        LABEL => episodes[idx].title(),
                        SUBLABEL => null,
                        METHOD => episodes[idx].id(),
                    });
                }

                // loading finished
                d_loading = false;
                MenuBase.onLoaded(null);
            }

            function placeholder() {
                if (d_loading) {
                    return WatchUi.loadResource(Rez.Strings.fetchingEpisodes);
                }
                return WatchUi.loadResource(Rez.Strings.placeholder_noRemoteEpisodes);
            }

            function onError(error) {
                // loading finished
                d_loading = false;
                MenuBase.onLoaded(error);
            }
        }
    }
}