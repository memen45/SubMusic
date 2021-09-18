using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class EpisodesRemote extends MenuBase {

            private var d_loading = false;
	        private var d_provider = SubMusic.Provider.get();
            private var d_id;       // store id of podcast channel

            function initialize(title, id) {
                // initialize base as not loaded
                MenuBase.initialize(title, false);

                d_id = id;

                // items should be lazy loaded by a menu loader
                // this prevents multiple concurrent requests
            }

            function load() {
                System.println("Menu.EpisodesRemote::load()");

                // if already loading, do nothing, wait for response
                if (d_loading) {
                    return false;
                }

                // start loading
                d_loading = true;
                
                // set fallback before request. future: fix with request object
                d_provider.setFallback(method(:onError));
                d_provider.getEpisodes(d_id, [0, 5], method(:onGetEpisodes));
                // var deferrable = d_deferrableFactory.invoke();
                // deferrable.run()
                return false;
            }

            function onGetEpisodes(episodes) {

                // store in class
                var items = [];
                for (var idx = 0; idx != episodes.size(); ++idx) {
                    //d_items.add(new Menu.EpisodeSettingsRemote(episodes[idx]));
                    items.add({
                        LABEL => episodes[idx].title(),
                        SUBLABEL => null,
                        METHOD => episodes[idx].id(),
                    });
                }

                // loading finished
                MenuBase.load(items);

                // update the view as it might be textview still
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

            function onBack() {
                // try and cancel the outstanding requests
                Communications.cancelAllRequests();
                return false;
            }

            function delegate() {
                return new MenuDelegate(null, method(:onBack));
            }
        }
    }
}