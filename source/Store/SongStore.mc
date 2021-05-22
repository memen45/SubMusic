using Toybox.System;
using Toybox.Application;

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

	function get(id) {
//		System.println("SongStore::get( id : " + id + " )");

		return d_songs.get(id);
	}

	function getIds() {
		System.println("SongStore::getIds()");

		return d_songs.getIds();
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
		System.println("SongStore::save( song : " + song.toStorage() + " )");

		// update delete tracking
		var id = new Id(song.id());
		var delete = (song.refCount() <= 0);
		var ondelete = (d_delete.indexOf(id) >= 0);
		if (delete && !ondelete) {
			d_delete.add(id);
		} else if (!delete && ondelete) {
			d_delete.remove(id);
		}

		// save details of the song
		return d_songs.save(song);
	}

	function remove(song) {
		System.println("SongStore::remove( " + song.toStorage() + ")");

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