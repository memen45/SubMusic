using Toybox.WatchUi;

module SubMusic {
    module Menu {

        class PlaylistsRemoteToggle extends MenuBase {

	        private var d_provider = SubMusic.Provider.get();
            private var d_loading = false;

            function initialize(title) {
                MenuBase.initialize(title, false);

                d_provider.setFallback(method(:onError));

                // items are lazy loaded by a menu loader
            }

            function getItem(idx) {

                if (items() == null) {
                    return null;
                }
                
                // check if out of bounds
                if (idx >= items().size()) {
                    return null;
                }

                // load playlist from array
                var playlist = items()[idx];

                // create checkbox menuitem
                var label = playlist.name();
                var sublabel = playlist.count().toString() + " songs";
                if (!playlist.remote()) {
                    sublabel += " - local only";
                }
                var enabled = playlist.local();
                return new WatchUi.ToggleMenuItem(label, sublabel, playlist, enabled, {});
            }

            function playlist_to_item(playlist) {
                var label = playlist.name();
                var sublabel = playlist.count().toString() + " songs";
                if (!playlist.remote()) {
                    sublabel += " - local only";
                }
                var enabled = playlist.local();
                return new WatchUi.ToggleMenuItem(label, sublabel, playlist, enabled, {});
            }

            function load() {

                // if already loading, do nothing, wait for response
                if (d_loading) {
                    return false;
                }

                // load locals 
                var ids = PlaylistStore.getIds();
                for (var idx = 0; idx != ids.size(); ++idx) {
                    items().add(new IPlaylist(ids[idx]));
                }

                // start loading
                d_loading = true;
                d_provider.getAllPlaylists(method(:onGetAllPlaylists));
                return false;
            }

            function onGetAllPlaylists(playlists) {

                var ids = PlaylistStore.getIds();

                var items = [];
                var items_remote = [];

                // iterate over remotes first 
                for (var idx = 0; idx < playlists.size(); ++idx) {
                    var playlist = playlists[idx];
                    var id = playlist.id();

                    // nothing to update if not stored locally
                    if (ids.indexOf(id) < 0) {
                        items_remote.add(playlist);		// add to the remote items list
                        continue;
                    }

                    // if stored, update
                    var iplaylist = new IPlaylist(id);
                    iplaylist.setRemote(playlist.remote());
                    items.add(iplaylist);					// add to the items list
                    ids.remove(id);							// this id is updated already, so remove from the list
                }

                // update remote state if not found on remote lists
                for (var idx = 0; idx < ids.size(); ++idx) {
                    var iplaylist = new IPlaylist(ids[idx]);
                    iplaylist.setRemote(false);
                    items.add(iplaylist);				// add to the items list
                }

                // append remotes to the stored ones
                items.addAll(items_remote);

                // load items 
                MenuBase.load(items);

                // update the view accordingly
                MenuBase.onLoaded(null);
            }

            function placeholder() {
                if (d_loading) {
                    return WatchUi.loadResource(Rez.Strings.placeholder_noRemotePlaylists);
                }
                return WatchUi.loadResource(Rez.Strings.fetchingPlaylists);
            }

            function onError(error) {
                // loading finished
                d_loading = false;
                MenuBase.onLoaded(error);
            }

            function onPlaylistToggle(item) {
                var playlist = item.getId();
                var id = playlist.id();
                var iplaylist = new IPlaylist(id);

                // update local
                iplaylist.setLocal(item.isEnabled());

                if (item.isEnabled()) {
                    iplaylist.updateMeta(playlist);
                }
            }

            function delegate() {
                return new MenuDelegate(method(:onPlaylistToggle), null);
            }
        }
    }
}