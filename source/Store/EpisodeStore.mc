using Toybox.System;
using Toybox.Application;
using SubMusic.Storage;

/**
 * module EpisodeStore
 * 
 * access to application storage for episodes
 */

module EpisodeStore {

	var d_episodes = new ObjectStore(Storage.EPISODES);			// allows fast indexing by id
	
	function get(id) {
//		if ($.debug) {
//			System.println("EpisodeStore::get( id : " + id + " )");
//		}

		return d_episodes.get(id);
	}

	function getIds() {
		if ($.debug) {
			System.println("EpisodeStore::getIds()");
		}

		return d_episodes.getIds();
	}

    // these functions should be used only internally by IEpisode class
	function save(episode) {
		if ($.debug) {
			System.println("EpisodeStore::save( episode : " + episode.toStorage() + " )");
		}

		// save details of the episode
		return d_episodes.save(episode);
	}

	function remove(episode) {
		if ($.debug) {
			System.println("EpisodeStore::remove( " + episode.toStorage() + ")");
		}

		// remove from storage
		d_episodes.remove(episode);
	}
}