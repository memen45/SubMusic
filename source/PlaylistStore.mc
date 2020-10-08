using Toybox.System;
using Toybox.Application;

module PlaylistStore {
	
	// dictionary by playlist id (all saved playlists)
	var d_playlists = {};
	var d_initialized = false;

	function initialize() {
		System.println("PlaylistStore::initialize()");

		var playlists = Application.Storage.getValue(Storage.PLAYLISTS);
		if (playlists != null) {
			d_playlists = playlists;
		}
		d_initialized = true;
	}

	// returns a connected playlist
	function get(id) {
		System.println("PlaylistStore::get( id : " + id + " )");
		if (id == null)  {
			return null;
		}

		if (!d_initialized) {
			initialize();
		}
		return d_playlists.get(id);
	}

	function getIds() {
		System.println("PlaylistStore::getIds()");
		if (!d_initialized) {
			initialize();
		}
		
		return d_playlists.keys();
	}
	
	function save(playlist) {
		System.println("PlaylistStore::save( playlist : " + playlist.toStorage() + " )");
		
		// initialize if needed
		if (!d_initialized) {
			initialize();
		}

		// return false if failed save
		var id = playlist.id();
		if (id == null) {
			return false;
		}
		
		// save details of the playlist
		d_playlists.put(id, playlist.toStorage());
		Application.Storage.setValue(Storage.PLAYLISTS, d_playlists);

		// indicate successful save
		return true;
	}

	// returns true if playlist id entry removed from storage or is not in storage
	function remove(playlist) {
        var id = playlist.id();
        
		System.println("PlaylistStore::remove( id : " + id + " )");
		if (id == null)  {
			return true;
		}

		if (!d_initialized) {
			initialize();
		}

		d_playlists.remove(id);
		Application.Storage.setValue(Storage.PLAYLISTS, d_playlists);
		return true;
	}
}