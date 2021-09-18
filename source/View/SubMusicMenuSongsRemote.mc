using Toybox.WatchUi;
using SubMusic.Menu;

module SubMusic {
    module Menu {
        class SongsRemote extends MenuBase {

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
                System.println("Menu.SongsRemote::load()");

                // if already loading, do nothing, wait for response
                if (d_loading) {
                    return false;
                }

                // start loading
                d_loading = true;

                // set fallback before request. future: fix with request object
                d_provider.setFallback(method(:onError));
                d_provider.getPlaylistSongs(d_id, method(:onGetPlaylistSongs));
                return loaded();
            }

            function onGetPlaylistSongs(songs) {
                var items = [];
                for (var idx = 0; idx != songs.size(); ++idx) {
                    //d_items.add(new Menu.SongSettingsRemote(songs[idx]));
                    items.add({
                        LABEL => songs[idx].title(),
                        SUBLABEL => songs[idx].artist(),
                        METHOD => songs[idx].id(),
                    });
                }
                MenuBase.load(items);
                
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