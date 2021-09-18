using Toybox.WatchUi;
using Toybox.Application;

module SubMusic {
    module Menu {

        class PlaylistsLocal extends MenuBase {

            function initialize(title) {
                // initialize base as loaded
                MenuBase.initialize(title, false);
            }

            // reload the ids on request
			function load() {
                System.println("Menu.PlaylistsLocal::load()");
                
                var playlists = [];
                var ids = PlaylistStore.getIds();

                // remove the non local playlist ids
                var todelete = [];
                for (var idx = 0; idx != ids.size(); ++idx) {
                    var id = ids[idx];
                    var iplaylist = new IPlaylist(id);
                    if (iplaylist.local()) {
                        playlists.add(iplaylist);
                    }
                }

                // create the menu items
                var items = [];
                for (var idx = 0; idx != playlists.size(); ++idx) {
                    items.add(new Menu.PlaylistSettings(playlists[idx]));
                }
				return MenuBase.load(items);
			}
        }

        class LocalPlaylistsItemLoader extends Deferrable {
            function initialize() {
                Deferrable.initialize(method(:load), method(:onDone), method(:onFail));
            }

            function load() {
                var playlists = [];
                var ids = PlaylistStore.getIds();

                // remove the non local playlist ids
                var todelete = [];
                for (var idx = 0; idx != ids.size(); ++idx) {
                    var id = ids[idx];
                    var iplaylist = new IPlaylist(id);
                    if (iplaylist.local()) {
                        playlists.add(iplaylist);
                    }
                }

                // create the menu items
                d_items = [];
                for (var idx = 0; idx != playlists.size(); ++idx) {
                    d_items.add(new Menu.PlaylistSettings(playlists[idx]));
                }

                // mark complete 
                return Deferrable.complete();
            }
        }
    }
}