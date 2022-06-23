using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class AlbumsRemote extends MenuBase {

	        private var d_provider = SubMusic.Provider.get();
            private var d_loading = false;
            private var d_id;       // store id of artist

            function initialize(title, id) {
                // initialize base as not loaded
                MenuBase.initialize(title, false);

                d_id = id;

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
                d_provider.getAlbums(d_id, method(:onGetAlbums));
                return false;
            }

            function onGetAlbums(albums) {
                // store in class
                var items = [];
                for (var idx = 0; idx != albums.size(); ++idx) {
                    items.add(new Menu.AlbumSettingsRemote(albums[idx]));
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