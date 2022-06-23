// playlist connection to store
class IAlbum extends IPlaylist {

	// override store get, save and remove
	function store_get(id) {
		return AlbumStore.get(id);
	}

	function store_save(obj) {
		return AlbumStore.save(obj);
	}

	function store_remove(obj) {
		return AlbumStore.remove(obj);
	}
}