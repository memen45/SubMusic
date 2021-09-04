using Toybox.Media;
using Toybox.Application;

// Keys for Storage
module Storage_Deprecated {
	enum {
		PLAYLIST,
		SONGS_LOCAL,
		PLAYLIST_LOCAL,
		PLAYLIST_SYNC,
		PLAYLIST_DELETE,
		
		SONGS_SYNC,
		SONGS_DELETE,
	}
}

module Storage {
	enum {
		PLAYABLE,		// playable dictionary 

		SONGS,			// dictionary where song id is key
		SONGS_DELETE,	// array of song ids of todelete songs (refCount == 0)
		PLAYLISTS,		// dictionary where playlist id is key
		
		LAST_SYNC,		// dictionary with details on last sync 

		PLAY_RECORDS,	// array with play_record objects (scrobble)

		SYNC_REQUEST,	// stores boolean true if sync was requested by user

		ARTWORK,		// dictionary where art id is key
		ARTWORK_DELETE,	// array of artwork ids of todelete artwork (refCount == 0)
		ARTWORK_PREFIX,	// starting code for all artwork storage keys (max size per key)

		PODCASTS,		// dictionary where podcast id is key
		EPISODES,		// dictionary where episodes id is key
		SONGS_TODO,		// array of song ids of todo songs (refId == null)

		VERSION = 200,	// version string of store
	}

	function check() {
		var current = new SubMusicVersion(null);
		
		var storage = Application.Storage.getValue(VERSION);
		if (storage == null) {
			// normally: new install
			// for Version.V0_0_16_PI only: fix storage if available
			tryFixDeprecated();

			// store current version number to storage
			Application.Storage.setValue(VERSION, current.toStorage());
			return;
		}
		
		var previous = new SubMusicVersion(storage);
		if (current.compare(previous) == 0) {
			// same version, nothing to do
			return;
		}

		// below 0.1.4, playable was playlist id, due to bug in 0.1.4, this is now set to 0.1.5
		var version = new SubMusicVersion({"major" => 0, "minor" => 1, "patch" => 5});
		if (previous.lessthan(version)) {
			Application.Storage.setValue(PLAYABLE, null);
		}

		// update stored version
		Application.Storage.setValue(VERSION, current.toStorage());

		// future should provide code here to update existing storages
	}

	// this can be removed in later versions as this translates storage from pre 0.0.16
	function tryFixDeprecated() {
		// check if any existing playlists
		var playlists = Application.Storage.getValue(Storage_Deprecated.PLAYLIST_LOCAL);
		if (playlists == null) {
			Application.Storage.clearValues();
			return;
		}

		// check if any existing songs
		var songs = Application.Storage.getValue(Storage_Deprecated.SONGS_LOCAL);
		
		// clear all persistent storage (we have copies now)
		Application.Storage.clearValues();
		
		// if no songs to recover, return
		if (songs == null) {
			return;
		}

		// here we have both playlists and songs

		// store playlist ids
		var pl_ids = playlists.keys();
		for (var idx = 0; idx < pl_ids.size(); ++idx) {
			var playlist = new IPlaylist(pl_ids[idx]);
			playlist.setLocal(true);
			playlist.setName(playlists[pl_ids[idx]]["name"]);
			playlist.setCount(playlists[pl_ids[idx]]["songCount"]);
			playlist.setRemote(true);
		}

		// safely remove all songs from cache
		var refIds = songs.keys();
		for (var idx = 0; idx < refIds.size(); ++idx) {
			var refId = refIds[idx];
			if (refId != null) {
				// remove from media cache
				var contentRef = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
				Media.deleteCachedItem(contentRef);
			}
		}
	}
}

module ApiStandard {
	enum {
		SUBSONIC = 0,
		AMPACHE = 1,
	}
}
