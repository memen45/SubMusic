using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class PlaylistsRemote extends MenuBase {

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
                	System.println("Menu.PlaylistsRemote::load()");
                }

                // if already loading, do nothing, wait for response
                if (d_loading) {
                    return false;
                }

                // start loading
                d_loading = true;
                
                // set fallback before request. future: fix with request object
                d_provider.setFallback(method(:onError));
                d_provider.getAllPlaylists(method(:onGetAllPlaylists));
                return false;
            }

            function onGetAllPlaylists(playlists) {
                // store in class
                var items = [];
                for (var idx = 0; idx != playlists.size(); ++idx) {
                    items.add(new Menu.PlaylistSettingsRemote(playlists[idx]));
                }
                MenuBase.load(items);

                d_loading = false;
                MenuBase.onLoaded(null);
            }

            function placeholder() {
                if (d_loading) {
                    return WatchUi.loadResource(Rez.Strings.fetchingPlaylists);
                }
                return WatchUi.loadResource(Rez.Strings.placeholder_noRemotePlaylists);
            }

            function onError(error) {
                // loading finished
                d_loading = false;
                MenuBase.onLoaded(error);
            }
        }
    }
}