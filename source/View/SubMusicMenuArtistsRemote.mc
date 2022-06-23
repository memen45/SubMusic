using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class ArtistsRemote extends MenuBase {

	        private var d_provider = SubMusic.Provider.get();
            private var d_loading = false;

            function initialize(title) {
                // initialize base as not loaded
                MenuBase.initialize(title, false);

                // items should be lazy loaded by a menu loader
                // this prevents multiple concurrent requests
            }

            function load() {
                System.println("Menu.AlbumsRemote::load()");

                // if already loading, do nothing, wait for response
                if (d_loading) {
                    return false;
                }

                // start loading
                d_loading = true;
                
                // set fallback before request. future: fix with request object
                d_provider.setFallback(method(:onError));
                d_provider.getArtists(method(:onGetArtists));
                return false;
            }

            function onGetArtists(artists) {
                // store in class
                var items = [];
                for (var idx = 0; idx != artists.size(); ++idx) {
                    items.add(new Menu.AlbumsRemote(artists[idx].name(), artists[idx].id()));
                }
                MenuBase.load(items);

                d_loading = false;
                MenuBase.onLoaded(null);
            }

            function placeholder() {
                if (d_loading) {
                    return WatchUi.loadResource(Rez.Strings.fetchingAlbums);
                }
                return WatchUi.loadResource(Rez.Strings.placeholder_noRemoteAlbums);
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