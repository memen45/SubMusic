using Toybox.System;
using Toybox.Application;

class Podcast {
	
	// required external playlist properties
	hidden var d_id;
	hidden var d_name;
    hidden var d_description;
	
	// optional external playlist properties
	hidden var d_episodes = [];		// array of episode ids
		
	// required internal playlist properties
	// hidden var d_time = 0;			// total playing time of the playlist in seconds
	
	hidden var d_remote = false; 	// true if metadata remotely available (according to last check)
	hidden var d_synced = false;	// true if no songs failed during sync -> or track by date last synced?
	
	// hidden var d_linked = false;	// true if all songs are referenced in their refCount
	hidden var d_local = false;		// true if should be locally available, false if should not

	
	function initialize(storage) {
		// System.println("Playlist::initialize( storage = " + storage + " )");
		System.println("Playlist::initialize( id : " + storage.get("id") + " )");

		d_id = storage["id"];
		fromStorage(storage);
	}

	function fromStorage(storage) {
		d_name = storage["name"];
		d_description = storage["description"];
		
		if (storage["episodes"] != null) {
			d_episodes = storage["episodes"];
		}

        // TODO: check variables
		if (storage["time"] != null) {
			d_time = storage["time"];
		}
		if (storage["remote"] != null) {
			d_remote = storage["remote"];
		}
		if (storage["synced"] != null) {
			d_synced = storage["synced"];
		}
		if (storage["local"] != null) {
			d_local = storage["local"];
		}
		if (storage["linked"] != null) {
			d_linked = storage["linked"];
		}
	}
	
	function toStorage() {
		return {
			"id" => d_id,
			"name" => d_name,
			"description" => d_description,
			
			"episodes" => d_episodes,

            // TODO: check variables
			"time" => d_time,
			
			"linked" => d_linked,
			"remote" => d_remote,
			"synced" => d_synced,
			"local" => d_local,
		};
	}
	
	// getters
	function id() {
		return d_id;
	}
	
	function name() {
		return d_name;
	}
	
	function count() {
		return d_songCount;
	}
	
	function songs() {
		return d_songs;
	}
	
	function remote() {
		return d_remote;
	}
	
	function local() {
		return d_local;
	}
	
	function synced() {
		return d_synced;
	}
	
	function linked() {
		return d_linked;
	}
	
	function time() {
		return d_time;
	}
	
}

// playlist connection to store
class IPodcast extends Podcast {
	
	// storage access
	private var d_stored = false;		// true if playlist metadata is in storage

	function initialize(id) {
		System.println("IPlaylist::initialize( id : " + id + " )");
		var storage = PlaylistStore.get(id);
		if (storage != null) {
			d_stored = true;
		} else {
			storage = {"id" => id};		// nothing known yet except for id
		}

		Podcast.initialize(storage);
	}

	function stored() {
		return d_stored;
	}
	
	// setters
	function addSong(id) {
		d_songs.add(id);
	}
	
	function removeSong(id) {
		return d_songs.remove(id);
	}
	
	function setTime(time) {
		// nothing to do if not changed
		if (d_time == time) {
			return false;
		}
		d_time = time;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setLinked(linked) {
		// nothing to do if not changed
		if (d_linked == linked) {
			return false;
		}
		d_linked = linked;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setLocal(local) {
		// nothing to do if not changed
		if (d_local == local) {
			return false;
		}
		d_local = local;

		return save();		// forced save, as local
	}

	function setRemote(remote) {
		// nothing to do if not changed
		if (d_remote == remote) {
			return false;
		}
		d_remote = remote;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}

	function setSynced(synced) {
		// nothing to do if not changed
		if (d_synced == synced) {
			return false;
		}
		d_synced = synced;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setName(name) {
		// nothing to do if not changed
		if (name.equals(d_name)) {
			return false;
		}
		d_name = name;
		
		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setCount(count) {
		System.println("IPlaylist.setCount( count : " + count + " )");
		// nothing to do if not changed
		if (d_songCount == count) {
			return false;
		}
		d_songCount = count;
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
		for (var idx = 0; idx < d_songs.size(); ++idx) {
			var song = new ISong(d_songs[idx]);
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
		for (var idx = 0; idx < d_songs.size(); ++idx) {
			var song = new ISong(d_songs[idx]);
			song.incRefCount();
		}
		setLinked(true);
		save();
	}
	
	function updateMeta(playlist) {
		// System.println("IPlaylist::updateMeta( playlist: " + playlist.toStorage() + " )");
		System.println("IPlaylist::updateMeta( playlist )");
		
		var changed = setName(playlist.name());
		changed |= setCount(playlist.count());
		changed |= setRemote(playlist.remote());
		if (changed) {
			d_stored = save();
		}
	}
	
	// updates song list, returns array of song ids that are not yet locally available
	function update(songs) {
		
		var songs_now = new [d_songs.size()];
		for (var idx = 0; idx < songs_now.size(); ++idx) {
			songs_now[idx] = d_songs[idx];
		}
		var songs_new = [];
		
		// calculate time of the new playlist
		var time = 0;
		
		// find remote additions
		for (var idx = 0; idx < songs.size(); ++idx) {
			
			var id = songs[idx].id();
			if (id == null) {
				continue;
			}
			
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
		save();
		return songs_new;
	}
	
	// saves the playlist
	function save() {
		d_stored = PlaylistStore.save(self);
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
		d_stored = !PlaylistStore.remove(self);	
		return true;
	}
}
			