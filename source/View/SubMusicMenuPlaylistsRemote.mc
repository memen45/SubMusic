using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class PlaylistsRemote extends MenuBase {

            // menu items will be loaded in here 
            hidden var d_items = [];

	        private var d_provider = SubMusic.Provider.get();
            private var d_loading = false;

            function initialize(title) {
                // initialize base as not loaded
                MenuBase.initialize(title, false);

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
                
                // set fallback before request. future: fix with request object
                d_provider.setFallback(method(:onError));
                d_provider.getAllPlaylists(method(:onGetAllPlaylists));
            }

            function onGetAllPlaylists(playlists) {

                // store in class
                d_items = [];
                for (var idx = 0; idx != playlists.size(); ++idx) {
                    d_items.add(new Menu.PlaylistSettingsRemote(playlists[idx]));
                }

                // loading finished
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