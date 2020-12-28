using Toybox.WatchUi;

module SubMusic {
    module Menu {

        class PlaylistsRemote {

            var title;

            // items not known at creation
            private var d_items = null;

	        private var d_provider = SubMusic.Provider.get();
            private var d_loading = false;
            private var f_onLoaded;

            function initialize(title) {
                self.title = title;

                d_provider.setFallback(method(:onError));
            }

            function getItem(idx) {

                if (d_items == null) {
                    return null;
                }
                
                // check if out of bounds
                if (idx >= d_items.size()) {
                    return null;
                }

                // load playlist from array
                var playlist = d_items[idx];

                // create checkbox menuitem
                var label = playlist.name();
                var sublabel = playlist.count().toString() + " songs";
                if (!playlist.remote()) {
                    sublabel += " - local only";
                }
                var enabled = playlist.local();
                return new WatchUi.ToggleMenuItem(label, sublabel, playlist, enabled, {});
            }

            function loaded() {
                if (d_items != null) {
                    return true;
                }

                if (d_loading) {
                    return false;
                }

                // start loading
                d_loading = true;
                d_provider.getAllPlaylists(method(:onGetAllPlaylists));
                return false;    // not yet loaded
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

                // store in class
                d_items = items;

                // loading finished
                d_loading = false;

                f_onLoaded.invoke();
            }

            function placeholder() {
                return "Fetching remote playlists";
            }

            function setOnLoaded(callback) {
                f_onLoaded = callback;
            }

            function onError(error) {    	
                WatchUi.switchToView(new ErrorView(error), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
            }
        }

        class PlaylistsRemoteView extends MenuView {
            function initialize(title) {
                MenuView.initialize(new PlaylistsRemote(title));
            }
        }

        class PlaylistsRemoteDelegate extends MenuDelegate {
            function initialize() {
                MenuDelegate.initialize(method(:onPlaylistToggle), null);
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
        }
    }
}