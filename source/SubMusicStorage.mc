// Keys for Storage

module Storage {
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

module ApiStandard {
	enum {
		SUBSONIC = 0,
		AMPACHE = 1,
	}
}