using Toybox.System;
using Toybox.Application;

class Podcast extends Storable {

	hidden var d_storage = {
		"id" => null,
		"name" => "default",
		"description" => "default",
		"art_id" => null,

		"episodes" => [],
		"time" => 0,

		"remote" => false,
		"synced" => false,

		"linked" => false,
		"local" => false,

		"podcast" => true,
	};
	
	// required external playlist properties
	// hidden var d_id;
	// hidden var d_name = "default";
	// hidden var d_description = "default";
	// hidden var d_copyright = "";
	
	// // optional external playlist properties
	// hidden var d_episodes = [];		// array of episode ids
		
	// // required internal playlist properties	
	// hidden var d_remote = false; 	// true if metadata remotely available (according to last check)
	// hidden var d_synced = false;	// true if no episodes failed during sync -> or track by date last synced?
	
	// hidden var d_linked = false;	// true if all episodes are referenced in their refCount
	// hidden var d_local = false;		// true if should be locally available, false if should not

	// hidden var d_podcast = true;	// true if playback position is stored, 

	
	function initialize(storage) {
		// System.println("Playlist::initialize( storage = " + storage + " )");
		System.println("Podcast::initialize( storage : " + storage + " )");

		Storable.initialize(storage);
	}

	// function fromStorage(storage) {
	// 	var changed = false;

	// 	// iterate over all keys 
	// 	var keys = d_storage.keys();
	// 	for (var idx = 0; idx != keys.size(); ++idx) {
	// 		var key = keys[idx];

	// 		// update value if not null and not equal
	// 		if ((storage[key] != null) && (d_storage[key] != storage[key])) {
	// 			d_storage[key] = storage[key];
	// 			changed = true;
	// 		}
	// 	}

	// 	return changed;
	// }
	
	// function toStorage() {
	// 	return d_storage;
	// }
	
	// getters
	function id() {
		return d_storage["id"];
	}
	
	function name() {
		return d_storage["name"];
	}
	
	function description() {
		return d_storage["description"];
	}
	
	function art_id() {
		return d_storage["art_id"];
	}

	function artwork() {
		if (art_id() == null) {
			return null;
		}

		var artwork = new IArtwork(art_id());
		return artwork.get();
	}
	
	function episodes() {
		return d_storage["episodes"];
	}

	function time() {
		return d_storage["time"];
	}
	
	function remote() {
		return d_storage["remote"];
	}
	
	function synced() {
		return d_storage["synced"];
	}

	function linked() {
		return d_storage["local"];
	}

	function local() {
		return d_storage["local"];
	}

	function podcast() {
		return d_storage["podcast"];
	}
	
}

// podcast connection to store
class IPodcast extends Podcast {
	
	// storage access
	private var d_stored = false;		// true if podcast metadata is in storage

	function initialize(id) {
		System.println("IPodcast::initialize( id : " + id + " )");
		var storage = PodcastStore.get(id);
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
	function addEpisode(id) {
		d_storage["episodes"].add(id);
	}
	
	function removeEpisode(id) {
		return d_storage["episodes"].remove(id);
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

	function setString(key, string) {
		// not a valid string? do not update
		if (string == null) {
			return false;
		}

		// nothing to do if not changed
		if (d_storage[key].equals(string)) {
			return false;
		}
		d_storage[key] = string;

		// nothing to do if not stored
		if (d_stored) {
			save();
		}
		return true;
	}
	
	function setName(name) {
		return setString("name", name);
	}

	function setDescription(description) {
		return setString("description", description);
	}

	function setArt_id(art_id) {
		// if equal, nothing to do
		if (art_id() == art_id) {
			return false;
		}

		if (!linked()) {
			d_storage["art_id"] = art_id;
			return true;
		}

		// if previous art_id stored and linked, deref
		if (art_id() != null) {
			var iartwork = new IArtwork(art_id());
			iartwork.decRefCount();
		}
		d_storage["art_id"] = art_id;

		// if new artwork null, nothing to do
		if (art_id == null) {
			return true;
		}

		// reference the new artwork
		var iartwork = new IArtwork(art_id);
		iartwork.incRefCount();
		return true;
	}
	 
	function setArtwork(artwork) {
		var iartwork = new IArtwork(art_id());
		return iartwork.set(artwork);
	}

// 	function setPodcast(podcast) {
// 		// nothing to do if not changed
// 		if (d_podcast == podcast) {
// 			return false;
// 		}
// 		d_podcast = podcast;

// 		// nothing to do if not stored
// 		if (d_stored) {
// 			save();
// 		}
// 		return true;
// 	}
	
// 	function setCount(count) {
// 		System.println("IPlaylist.setCount( count : " + count + " )");
// 		// nothing to do if not changed
// 		if (d_songCount == count) {
// 			return false;
// 		}
// 		d_songCount = count;
// 		// nothing to do if not stored
// 		if (d_stored) {
// 			save();
// 		}
// 		return true;
// 	}

	// unlinks all related refs (only artwork)
	function unlink() {
		System.println("IPodcast::unlink()");
		// nothing to do if not linked
		if (!linked()) {
			return;
		}
		
		// unlink artwork
		var iartwork = new IArtwork(art_id());
		iartwork.decRefCount();

		for (var idx = 0; idx != episodes().size(); ++idx) {
			var episode = new IEpisode(episodes()[idx]);
			episode.remove();	// remove from store
		}

		setLinked(false);
		save();
	}
	
	// links all related refs (only artwork)
	function link() {
		System.println("IPodcast::link()");
		
		// nothing to do if already linked
		if (linked()) {
			return;
		}
	
		// link artwork
		var iartwork = new IArtwork(art_id());
		iartwork.incRefCount();

		for (var idx = 0; idx != episodes().size(); ++idx) {
			var episode = new IEpisode(episodes()[idx]);
			episode.save();		// save metadata, will be downloaded on next sync
		}

		setLinked(true);
		save();
	}
	
	function updateMeta(podcast) {
		System.println("IPodcast::updateMeta( podcast: " + podcast.toStorage() + " )");
		
		var changed = setName(podcast.name());
		changed |= setDescription(podcast.description());
		changed |= setArt_id(podcast.art_id());
		changed |= setRemote(podcast.remote());
		if (changed) {
			d_stored = save();
		}
	}
	
	// updates episodes list, returns array of episode ids that are not yet locally available
	function update(episodes) {
		
		// keep track of current episodes
		var episodes_now = new [episodes().size()];
		for (var idx = 0; idx < episodes_now.size(); ++idx) {
			episodes_now[idx] = episodes()[idx];
		}

		// keep track of newly added episodes
		var episodes_new = [];

		// keep track of order of remote playlist
		var episodes_ord = [];
		
		// calculate time of the new playlist
		var time = 0;
		
		// find remote additions
		for (var idx = 0; idx < episodes.size(); ++idx) {
			
			var id = episodes[idx].id();
			if (id == null) {
				continue;
			}

			// add it to the new episode ids (order preserved)
			episodes_ord.add(id);
			
			// update information of the episode
			var iepisode = new IEpisode(id);
			iepisode.updateMeta(episodes[idx]);		// update and save episode details
			
			// add to the time total
			time += iepisode.time();
			
			// add to tosync list if linked, but not downloaded
			if (linked() && (iepisode.refId() == null)) {
				episodes_new.add(id);
			}
			
			// if remove returns true, it was already on the old list, so nothing to do
			if (episodes_now.remove(id)) {
				continue;
			}
			
			// add it to the playlist
			addEpisode(id);
			
			// if linked, increment reference count of the episode
			if (linked()) {
				iepisode.save();	// directly save to storage
			}
			
		}
		setTime(time);
		
		// find extra's on playlist
		for (var idx = 0; idx < episodes_now.size(); ++idx) {
			var id = episodes_now[idx];
			var iepisode = new IEpisode(id);
			
			// if linked, decrement reference count of the episode
			if (linked()) {
				iepisode.remove();		// directly remove from storage
			}
			
			// remove from playlist
			removeEpisode(id);
		}

		// order of episodes should be copied from server
		d_storage["episodes"] = episodes_ord;

		save();
		return episodes_new;
	}
	
	// saves the podcast
	function save() {
		d_stored = PodcastStore.save(self);
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

		// remove references to episodes
		var eps = episodes();
		for (var idx = 0; idx != eps.size(); ++idx) {
			var ep = new IEpisode(eps[idx]);
			ep.setRefId(null);
		}

		setArt_id(null);			// remove reference to art_id
		d_stored = !PlaylistStore.remove(self);	
		return true;
	}
}
			