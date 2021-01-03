using Toybox.WatchUi;
using Toybox.Application;

module SubMusic {
    module Menu {

        class PlaylistsLocal extends MenuBase {

            // items are known at creation
            private var d_ids;

            function initialize(title) {
                // initialize base as loaded
                MenuBase.initialize(title, true);

                // load the items
                load();
            }
            
            function getItem(idx) {

                // check if out of bounds
                if (idx >= d_ids.size()) {
                    return null;
                }

                // load the menuitem
                var id = d_ids[idx];
                var iplaylist = new IPlaylist(id);
                var label = iplaylist.name();
                var mins = (iplaylist.time() / 60).toNumber().toString();
                var sublabel = mins + " mins";
                if (!iplaylist.synced()) {
                    sublabel += " - needs sync";
                }

                // create the menu item
                return new WatchUi.MenuItem(
                    label,		// label
                    sublabel,	// sublabel
                    id,		    // identifier (use method for simple callback)
                    null		// options
			    );
            }

            // reload the ids on request
			function load() {
                d_ids = PlaylistStore.getIds();

                // remove the non local playlists
                var todelete = [];
                for (var idx = 0; idx != d_ids.size(); ++idx) {
                    var id = d_ids[idx];
                    var iplaylist = new IPlaylist(id);
                
                    // if not local, no menu entry is added
                    if (!iplaylist.local()) {
                        todelete.add(id);
                    }
                }
                for (var idx = 0; idx != todelete.size(); ++idx) {
                    d_ids.remove(todelete[idx]);
                }
			}
        }

        class PlaylistsLocalView extends MenuView {
            function initialize(title) {
                MenuView.initialize(new PlaylistsLocal(title));
            }
        }

        class PlaylistsLocalDelegate extends MenuDelegate {
            function initialize() {
                MenuDelegate.initialize(method(:onPlaylistSelect), null);
                // ids are ids, so have to be handled, no onBack action
            }

            function onPlaylistSelect(item) {
                var id = item.getId();

                var loader = new MenuLoader(
                    new PlaylistSettings(id),
                    new PlaylistSettingsDelegate()
                );
            }
        }
    }
}