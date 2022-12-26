using Toybox.Application;
using Toybox.System;
using SubMusic.Storage;

module SubMusic {
    module PlayableStore {

        var d_store = new Store(Storage.PLAYABLE, {});

        function get() {
            return d_store.value();
        }

        // these functions should be used only internally by IPlayable class
        function save(playable) {
            d_store.setValue(playable.toStorage());
            return d_store.update(); 
        }

        function remove() {
            d_store.setValue(null);
            return d_store.update();
        }
    }
}
