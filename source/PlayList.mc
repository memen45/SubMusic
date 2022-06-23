using Toybox.System;
using Toybox.Application;

class Playlist extends Storable {

	hidden var d_storage = {

		// required external playlist properties
        "id" => null,       			// id of the album
        "name" => "default",       		// name of the album
		"songCount" => 0,				// number of songs on the album
        "art_id" => null,   			// null if no art available

		// optional external playlist properties
		"songs" => [],					// array of album songs
		"time" => 0,					// total playing time in seconds

		// required internal playlist properties
		"remote" => false,				// true if metadata remotely available (according to last check)
		"synced" => false,				// true if no episodes failed during sync -> or track by date last synced?

		"linked" => false,				// true if all episodes are referenced in their refCount
		"local" => false,				// true if should be locally available, false if should not

		"podcast" => true,				// true if playback position is stored, 
    };
	
	function initialize(storage) {
		System.println("Playlist::initialize( storage : " + storage + " )");

		fromStorage(storage);
	}
	
	// getters
	function id() {
		return d_storage["id"];
	}
	
	function name() {
		return d_storage["name"];
	}

	function count() {
		return d_storage["songCount"];
	}

	function art_id() {
		return d_storage["art_id"];
	}
	
	function songs() {
		return d_storage["songs"];
	}
	
	function remote() {
		return d_storage["remote"];
	}
	
	function local() {
		return d_storage["local"];
	}
	
	function synced() {
		return d_storage["synced"];
	}
	
	function linked() {
		return d_storage["linked"];
	}
	
	function time() {
		return d_storage["time"];
	}

	function podcast() {
		return d_storage["podcast"];
	}
	
	function artwork() {
		if (art_id() == null) {
			return null;
		}

		var artwork = new IArtwork(art_id(), Artwork.SONG);
		return artwork.image();
	}
}

// playlist connection to store
class IPlaylist extends Playlist {
	
	// storage access
	private var d_stored = false;		// true if playlist metadata is in storage

	function initialize(id) {
		System.println("IPlaylist::initialize( id : " + id + " )");
		var storage = store_get(id);
		if (storage != null) {
			d_stored = true;
		} else {
			storage = {"id" => id};		// nothing known yet except for id
		}

		Playlist.initialize(storage);
	}

	function stored() {
		return d_stored;
	}

	function store_get(id) {
		return PlaylistStore.get(id);
	}

	function store_save(obj) {
		return PlaylistStore.save(obj);
	}

	function store_remove(obj) {
		return PlaylistStore.remove(obj);
	}
	
	// setters
	function addSong(id) {
		System.println("IPlaylist::addSong(id: " + id + " )");

		// add it to the array
		songs().add(id);
	}
	
	function removeSong(id) {
		return songs().remove(id);
	}
	
	function setTime(time) {
		// nothing to do if not changed
		if (time() == time) {
			return false;
		}
		d_storage["time"] = time;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setLinked(linked) {
		// nothing to do if not changed
		if (linked() == linked) {
			return false;
		}
		d_storage["linked"] = linked;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setLocal(local) {
		// nothing to do if not changed
		if (local() == local) {
			return false;
		}
		d_storage["local"] = local;

		return save();		// forced save, as local
	}

	function setRemote(remote) {
		// nothing to do if not changed
		if (remote() == remote) {
			return false;
		}
		d_storage["remote"] = remote;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function setSynced(synced) {
		// nothing to do if not changed
		if (synced() == synced) {
			return false;
		}
		d_storage["synced"] = synced;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setName(name) {
	
		if (name == null) {
			return false;
		}
	
		// nothing to do if not changed
		if (name().equals(name)) {
			return false;
		}
		d_storage["name"] = name;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function setPodcast(podcast) {
		// nothing to do if not changed
		if (podcast() == podcast) {
			return false;
		}
		d_storage["podcast"] = podcast;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setCount(count) {
		System.println("IPlaylist.setCount( count : " + count + " )");
		// nothing to do if not changed
		if (count() == count) {
			return false;
		}
		d_storage["songCount"] = count;
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	// unlinks all related songs
	function unlink() {
		System.println("IPlaylist::unlink()");
		// nothing to do if not linked
		if (!linked()) {
			return;
		}
		
		// unlink each of the songs
		var sngs = songs();
		for (var idx = 0; idx < sngs.size(); ++idx) {
			var song = new ISong(sngs[idx]);
			song.decRefCount();
		}
		setLinked(false);
		save();
	}
	
	// links all related songs
	function link() {
		System.println("IPlaylist::link()");
		
		// nothing to do if already linked
		if (linked()) {
			return;
		}
	
		// link each of the songs
		var sngs = songs();
		for (var idx = 0; idx < sngs.size(); ++idx) {
			var isong = new ISong(sngs[idx]);
			isong.incRefCount();
		}
		setLinked(true);
		save();
	}

	function updateMeta(playlist) {
		System.println("IPlaylist::updateMeta( playlist: " + playlist.toStorage() + " )");

		// only single save is needed, so mark as not stored temporarily
		d_stored = false;

		// update the variables
		var changed = setName(playlist.name());
		changed |= setCount(playlist.count());
		changed |= setRemote(playlist.remote());
		if (changed) {
			save();
		}
		d_stored = true;
	}
	
	// updates song list, returns array of song ids that are not yet locally available
	function update(songs) {
		System.println("IPlaylist::update() STARTING id:" + id() + " )");
		
		// keep track of current songs
		var songs_now = new [songs().size()];
		for (var idx = 0; idx < songs_now.size(); ++idx) {
			songs_now[idx] = songs()[idx];
		}

		// keep track of newly added songs
		var songs_new = [];

		// keep track of order of remote playlist
		var songs_ord = [];
		
		// calculate time of the new playlist
		var time = 0;
		
		// find remote additions
		for (var idx = 0; idx < songs.size(); ++idx) {
			
			var id = songs[idx].id();
			if (id == null) {
				continue;
			}

			// add it to the new song ids (order preserved)
			songs_ord.add(id);
			
			// update information of the song
			var isong = new ISong(id);
			isong.updateMeta(songs[idx]);		// update and save song details
			
			// add to the time total
			time += isong.time();
			
			// add to tosync list if linked, but not downloaded
			if (linked() && (isong.refId() == null)) {
				songs_new.add(id);
			}
			
			// if remove returns true, it was already on the old list, so nothing to do
			if (songs_now.remove(id)) {
				continue;
			}
			
			// add it to the playlist
			addSong(id);
			
			// if linked, increment reference count of the song
			if (linked()) {
				isong.incRefCount();
			}
			
		}
		setTime(time);
		
		// find extra's on playlist
		for (var idx = 0; idx < songs_now.size(); ++idx) {
			var id = songs_now[idx];
			var isong = new ISong(id);
			
			// if linked, decrement reference count of the song
			if (linked()) {
				isong.decRefCount();
			}
			
			// remove from playlist
			removeSong(id);
		}

		// order of songs should be copied from server
		d_storage["songs"] = songs_ord;

		save();
		return songs_new;
	}
	
	// saves the playlist
	function save() {
		d_stored = store_save(self);
		return d_stored;
	}
	
	// safely removes the playlist from Store, 
	function remove() {
		// if still linked, unlink
		if (linked()) {
			unlink();
		}

		// if not stored, do not remove
		if (!d_stored) {
			return false;
		}

		// remove 
		d_stored = !store_remove(self);	
		return true;
	}
}
			