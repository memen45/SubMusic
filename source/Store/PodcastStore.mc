using SubMusic.Storage;

module PodcastStore {
    var d_store = new ObjectStore(Storage.PODCASTS);

    function get(id) {
        return d_store.get(id);
    }

    function getIds() {
        return d_store.getIds();
    }

    function save(podcast) {
        return d_store.save(podcast);
    }

    function remove(podcast) {
        return d_store.remove(podcast);
    }
}
