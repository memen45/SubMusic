using Toybox.System;
using Toybox.Application;

module PlaylistStore {
    var d_store = new ObjectStore(Storage.PLAYLISTS);

    function get(id) {
        return d_store.get(id);
    }

    function getIds() {
        return d_store.getIds();
    }

    function save(playlist) {
        return d_store.save(playlist);
    }

    function remove(playlist) {
        return d_store.remove(playlist);
    }
}
