using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class SongsRemote extends MenuBase {

            // menu items will be loaded in here 
            hidden var d_items = [];

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

                // if already loading, do nothing, wait for response
                if (d_loading) {
                    return;
                }

                // start loading
                d_loading = true;

                // set fallback before request. future: fix with request object
                d_provider.setFallback(method(:onError));
                d_provider.getPlaylistSongs(d_id, method(:onGetPlaylistSongs));
            }

            function onGetPlaylistSongs(songs) {

                // store in class
                d_items = [];
                for (var idx = 0; idx != songs.size(); ++idx) {
                    //d_items.add(new Menu.SongSettingsRemote(songs[idx]));
                    d_items.add({
                        LABEL => songs[idx].title(),
                        SUBLABEL => songs[idx].artist(),
                        METHOD => songs[idx].id(),
                    });
                }

                // loading finished
                d_loading = false;
                MenuBase.onLoaded(null);
            }

            function placeholder() {
                if (d_loading) {
                    return WatchUi.loadResource(Rez.Strings.fetchingSongs);
                }
                return WatchUi.loadResource(Rez.Strings.placeholder_noRemoteSongs);
            }

            function onError(error) {
                // loading finished
                d_loading = false;
                MenuBase.onLoaded(error);
            }
        }
    }
}