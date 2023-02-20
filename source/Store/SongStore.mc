using Toybox.System;
using Toybox.Application;
using SubMusic.Storage;

/**
 * module SongStore
 * 
 * access to application storage for songs
 */
 
class Id {
 	private var d_id;
 	
 	function initialize(id) {
 		d_id = id;
 	}
 	
 	function toStorage() {
 		return d_id;
 	}
}

module SongStore {

	var d_songs = new ObjectStore(Storage.SONGS);			// allows fast indexing by id
	var d_delete = new ArrayStore(Storage.SONGS_DELETE);	// allows fast access 
	var d_todo = new ArrayStore(Storage.SONGS_TODO);		// allows fast access

	function get(id) {
//		if ($.debug) {
//			System.println("SongStore::get( id : " + id + " )");
//		}

		return d_songs.get(id);
	}

	function getIds() {
		if ($.debug) {
			System.println("SongStore::getIds()");
		}

		return d_songs.getIds();
	}

	function getTodos() {
		var ret = new [d_todo.size()];
		for (var idx = 0; idx != d_todo.size(); ++idx) {
			ret[idx] = d_todo.get(idx);
		}
		return ret;
	}

	function getDeletes() {
		var ret = new [d_delete.size()];
		for (var idx = 0; idx < d_delete.size(); ++idx) {
			ret[idx] = d_delete.get(idx);
		}
		return ret;
	}

    // these functions should be used only internally by ISong class
	function save(song) {
		if ($.debug) {
			System.println("SongStore::save( song : " + song.toStorage() + " )");
		}

		// update delete tracking
		var id = new Id(song.id());
		var delete = (song.refCount() <= 0);
		var ondelete = (d_delete.indexOf(id) >= 0);
		if (delete && !ondelete) {
			d_delete.add(id);
			d_todo.remove(id);
		} else if (!delete && ondelete) {
			d_delete.remove(id);
		}
		// update todo tracking
		var todo = (song.refId() == null);
		var ontodo = (d_todo.indexOf(id) >= 0);
		if (!delete && todo && !ontodo) {
			d_todo.add(id);
		} else if (!todo && ontodo) {
			d_todo.remove(id);
		}

		// save details of the song
		return d_songs.save(song);
	}

	// this is for fast property saving. refCount or refId changed? use save
	function quicksave(song) {
		// save details of the song
		return d_songs.save(song);
	}

	function remove(song) {
		if ($.debug) {
			System.println("SongStore::remove( " + song.toStorage() + ")");
		}

		// remove from storage
		d_songs.remove(song);

        // if not on delete, nothing to do
        var id = new Id(song.id());
        if (d_delete.indexOf(id) < 0) {
            return;
        }

		// remove from delete
        d_delete.remove(id);
	}
}