using Toybox.System;
using Toybox.Application;

/**
 * module SongStore
 * 
 * access to application storage for songs
 */

module SongStore {
	
	// dictionary by song id (all saved song)
	var d_songs = {};
	var d_delete = [];		// deletes are deferred to account for changing refCount
	var d_initialized = false;

	function initialize() {
		System.println("SongStore::initialize()");

		var songs = Application.Storage.getValue(Storage.SONGS);
		if (songs != null) {
			d_songs = songs;
		}
		var delete = Application.Storage.getValue(Storage.SONGS_DELETE);
		if (delete != null) {
			d_delete = delete;
		}
		d_initialized = true;
	}

	function get(id) {
		System.println("SongStore::get( id : " + id + " )");

		if (id == null)  {
			return null;
		}

		if (!d_initialized) {
			initialize();
		}
		return d_songs[id];
	}

	function getIds() {
		System.println("SongStore::getIds()");

		if (!d_initialized) {
			initialize();
		}
		return d_songs.keys();
	}

	function getDeletes() {

		if (!d_initialized) {
			initialize();
		}
		var ret = new [d_delete.size()];
		for (var idx = 0; idx < d_delete.size(); ++idx) {
			ret[idx] = d_delete[idx];
		}
		return ret;
	}

    // these functions should be used only by ISong class
	function save(song) {
		System.println("SongStore::save( song : " + song.toStorage() + " )");

		// initialize if needed
		if (!d_initialized) {
			initialize();
		}

		var id = song.id();
		if (id == null) {
			return false;
		}
		
		// save details of the song
		d_songs.put(id, song.toStorage());
		Application.Storage.setValue(Storage.SONGS, d_songs);
		
		// update delete tracking
		var delete = (song.refCount() <= 0);
		var ondelete = (d_delete.indexOf(id) >= 0);
		if (delete && !ondelete) {
			d_delete.add(id);
		} else if (!delete && ondelete) {
			d_delete.remove(id);
		}
		Application.Storage.setValue(Storage.SONGS_DELETE, d_delete);

		// indicate successful save
		return true;
	}

	function remove(song) {
        var id = song.id();

		System.println("SongStore::remove( id : " + id + " )");
		
        if (id == null)  {
			return;
		}

		if (!d_initialized) {
			initialize();
		}

		// remove from storage
		d_songs.remove(id);
		Application.Storage.setValue(Storage.SONGS, d_songs);

        // if not on delete, nothing to do
        if (d_delete.indexOf(id) < 0) {
            return;
        }

        d_delete.remove(id);
        Application.Storage.setValue(Storage.SONGS_DELETE, d_delete);
	}
}