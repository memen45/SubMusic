using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class PodcastsRemote extends MenuBase {

	        private var d_provider = SubMusic.Provider.get();
            private var d_loading = false;

            function initialize(title) {
                // initialize base as not loaded
                MenuBase.initialize(title, false);

                // items should be lazy loaded by a menu loader
                // this prevents multiple concurrent requests
            }

            function load() {
                if ($.debug) {
                	System.println("Menu.PodcastsRemote::load()");
                }

                // if already loading, do nothing, wait for response
                if (d_loading) {
                    return false;
                }

                // start loading
                d_loading = true;

                // set fallback before request. future: fix with request object
                d_provider.setFallback(method(:onError));
                d_provider.getAllPodcasts(method(:onGetAllPodcasts));
                return false;
            }

            function onGetAllPodcasts(podcasts) {

                // store in class
                var items = [];
                for (var idx = 0; idx != podcasts.size(); ++idx) {
                    items.add(new Menu.PodcastSettingsRemote(podcasts[idx]));
                }
                MenuBase.load(items);

                // update view as it may change
                d_loading = false;
                MenuBase.onLoaded(null);
            }

            function placeholder() {
                if (d_loading) {
                    return WatchUi.loadResource(Rez.Strings.fetchingPodcasts);
                    }
                return WatchUi.loadResource(Rez.Strings.placeholder_noRemotePodcasts);
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