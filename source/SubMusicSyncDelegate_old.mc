using Toybox.Application;
using Toybox.Communications;
using Toybox.Media;

// Performs the sync with the music provider
class SubMusicSyncDelegate_old extends Media.SyncDelegate {

    // playlists to sync or remove
    private var d_locallists;			// already synced before
    private var d_synclists;			// to be synced to local playlists
    private var d_deletelists;			// to be deleted from local playlists
    private var d_state;
    
    // songs to sync or remove
    private var d_songstore;
    private var d_songs_total;
    private var d_songs_count = 0;
    
    // api access
    private var d_api;
    

    // Constructor
    function initialize() {
        SyncDelegate.initialize();
        
        // get the local playlists
        d_locallists = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
        if (d_locallists == null) {
        	d_locallists = {};
        	Application.Storage.setValue(Storage.PLAYLIST_LOCAL, d_locallists);
        }
        
        // get the sync playlists
        d_synclists = Application.Storage.getValue(Storage.PLAYLIST_SYNC);
        if (d_synclists == null) {
        	d_synclists = {};
        	Application.Storage.setValue(Storage.PLAYLIST_SYNC, d_synclists);
        }
        
        // get the delete playlists
        d_deletelists = Application.Storage.getValue(Storage.PLAYLIST_DELETE);
        if (d_deletelists == null) {
        	d_deletelists = [];
        	Application.Storage.setValue(Storage.PLAYLIST_DELETE, d_deletelists);
        }
        
        d_songstore = new SubMusicSongStore();
        d_api = new SubSonicAPI(method(:onFail));
    }

    // Starts the sync with the system
    function onStartSync() {
        System.println("Sync started...");
        
        d_songs_total = 0;
        var keys = d_locallists.keys();
        for (var idx = 0; idx < keys.size(); ++idx) {
        	d_songs_total += d_locallists[keys[idx]]["songCount"];
        }
        keys = d_synclists.keys();
        for (var idx = 0; idx < keys.size(); ++idx) {
        	d_songs_total += d_synclists[keys[idx]]["songCount"];
        }
        for (var idx = 0; idx < d_deletelists.size(); ++idx) {
        	d_songs_total += d_locallists[d_deletelists[idx]]["songCount"];
        }
        
        // Step 1: Delete songs from locally removed playlists		-		syncNextPlaylistDelete();
        // Step 2: Synchronize local playlists with remote server 	+/-		syncNextPlaylistLocal();
        // Step 3: Synchronize added playlists with remote server 	+		syncNextPlaylistSync();
        // Step 4: Delete songs from local storage					-		deleteSongs();
        // Step 5: Download songs from server to local storage		+		syncNextSong();
        syncNextPlaylistDelete();
    }

    // Sync always needed to verify new songs on the server
    function isSyncNeeded() {
        return true;
    }
    
    /**
     * syncNextPlaylistLocal
     * 
     * request all songs in local lists and add/remove extra's or missing
     */
    function syncNextPlaylistLocal() {
    	var keys = d_locallists.keys();
    	
    	System.println("To Update Playlists: " + keys.size());
    	if (keys.size() == 0) {
    		syncNextPlaylistSync();
    		return;
    	}
    	
    	var context = d_locallists[keys[0]];
    	var id = context["id"];
    	
    	System.println("Syncing a local playlist: " + context["name"]);
    	
    	d_api.getPlaylist(id, method(:onNextPlaylistLocal), context);
    }
    
    function onNextPlaylistLocal(playlist, context) {
    	var nr_synced = 0;
    	var remotes = playlist["entry"];
    	var locals = context["entry"];
    	
    	// find remote additions (place on synclist)
    	for (var idx = 0; idx < remotes.size(); ++idx) {
    		var local = findById(remotes[idx]["id"], locals);
    		
    		// if song was on list, nothing changes
    		if (local != null) {
    			locals.remove(local);
    			nr_synced++;
    			continue;
    		}
    		
    		// add song if it was not already local
    		var is_local = d_songstore.addSong(remotes[idx]);
    		if (is_local) {
    			nr_synced++;
    		}
    	}
    	System.println("locals left: " + locals);
    	
    	// find local extra's (place on deletelist)
    	for (var idx = 0; idx < locals.size(); ++idx) {
    		d_songstore.subSong(locals[idx]);
    	}
    	
    	// remove from todos
    	d_locallists.remove(context["id"]);
    	
    	// update local playlist information
    	var locallists = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
    	locallists[context["id"]] = playlist;
    	Application.Storage.setValue(Storage.PLAYLIST_LOCAL, locallists);
    	
    	System.println("Synced a local playlist: " + context["name"]);
    	
    	// update the total counter
    	d_songs_total += playlist["songCount"];
    	d_songs_total -= context["songCount"];
    	
    	onSongSynced(nr_synced);
    	syncNextPlaylistLocal();
    }
    
    function findById(id, locals) {
    	for (var idx = 0; idx < locals.size(); ++idx) {
    		if (locals[idx]["id"].equals(id)) {
    			return locals[idx];
    		}
    	}
    	return null;
    }
    
    /**
     * syncNextPlaylistSync
     * 
     * request all songs in a playlist, add the missing songs to the songs to sync
     */
    function syncNextPlaylistSync() {
    	var keys = d_synclists.keys();
    	
    	System.println("To Sync Playlists: " + keys.size());
    	
    	// advance to next step if done
    	if (keys.size() == 0) {
    		deleteSongs();
    		return;	
    	}
    	var context = d_synclists[keys[0]];
    	var id = context["id"];
    	
    	System.println("Syncing a new playlist: " + context["name"]);
    	
    	d_api.getPlaylist(id, method(:onNextPlaylistSync), context);
    }
    
    function onNextPlaylistSync(playlist, context) {
    	var nr_synced = 0;
    	
    	var remotes = playlist["entry"];
    	
    	for (var idx = 0; idx < remotes.size(); ++idx) {
    		var local = d_songstore.addSong(remotes[idx]);
    		if (local) {
    			nr_synced++;
    		}
    	}
    	
    	// remove local playlist information
    	d_synclists = Application.Storage.getValue(Storage.PLAYLIST_SYNC);
    	d_synclists.remove(context["id"]);
    	Application.Storage.setValue(Storage.PLAYLIST_SYNC, d_synclists);
    	
    	// update local playlist information
    	var locallists = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
    	locallists[context["id"]] = playlist;
    	Application.Storage.setValue(Storage.PLAYLIST_LOCAL, locallists);
    	
    	System.println("Synced a new playlist: " + context["name"]);
    	
    	// update the total counter
    	d_songs_total += playlist["songCount"];
    	d_songs_total -= context["songCount"];
    	
    	onSongSynced(nr_synced);
    	syncNextPlaylistSync();
    }
    
    /**
     * syncNextPlaylistDelete
     * 
     * remove all songs from a playlist
     */
     function syncNextPlaylistDelete() {
     
     	System.println("To Delete Playlists:  " + d_deletelists.size());
     	
     	for (var idx = 0; idx < d_deletelists.size(); ++idx) {
     		var list_id = d_deletelists[idx];
     		
     		// get local songs from to delete playlist
	    	var locallists = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
	    	if (locallists[list_id] == null) {
	    		continue;
	    	}
     		var songs = locallists[list_id]["entry"];
     		
	     	for (var songidx = 0; songidx < songs.size(); ++songidx) {
	     		d_songstore.subSong(songs[songidx]);
	     	}
	     	// count as synced, since they need no sync on local list
	     	onSongSynced(songs.size());
	     	
	    	// update local playlist information
	    	System.println(locallists);
	    	locallists.remove(list_id);
	    	System.println(locallists);
	    	Application.Storage.setValue(Storage.PLAYLIST_LOCAL, locallists);
	    	
	    	// update delete playlist store
	    	var deletelists = Application.Storage.getValue(Storage.PLAYLIST_DELETE);
	    	deletelists.remove(list_id);
	    	Application.Storage.setValue(Storage.PLAYLIST_DELETE, deletelists);
	    }
     	d_deletelists = [];
     	
     	// prepare locallists
     	d_locallists = Application.Storage.getValue(Storage.PLAYLIST_LOCAL);
     	syncNextPlaylistLocal();
     }

    // Delete songs off the system
    function deleteSongs() {
		var count = d_songstore.flushDelete(method(:onSongSynced));
		System.println("Deleted: " + count + " songs from local storage");
		syncNextSong();
    }

    // Downloads the next song to be synced
    function syncNextSong() {
    	var song = null;// = d_songstore.getFrontSync();
    	if (song == null) {
    		//d_songstore.writeToStorage();		// make sure the store is saved
    		Media.notifySyncComplete(null);
    		return;
    	}
    	System.println("Syncing song " + song["title"] + " number " + d_songs_count + " of " + d_songs_total);
    	d_api.setFallback(method(:onSongDownloadFail));
    	d_api.stream(song["id"], "mp3", method(:onSongDownloaded), song);
    }

    // Callback for when a song is downloaded
    function onSongDownloaded(refId, song) {
    	d_songstore.storeSong(song["id"], refId);
    	
    	System.println("Synced song " + song["id"]);
    	
    	onSongSynced(1);
    	syncNextSong();
    }
    
    // fallback for failed download
    function onSongDownloadFail(responseCode, data, context) {
    	d_songstore.skipSong(context["id"]);
    
    	System.println("Sync failed " + context["id"]);
    	
    	onSongSynced(1);
    	syncNextSong();
    }

    // Update the system with the current sync progress
    function onSongSynced(count) {
    	d_songs_count += count;
    	
    	var progress = (100 * d_songs_count) / d_songs_total.toFloat();
    	progress = progress.toNumber();
    	
    	Media.notifySyncProgress(progress);
    }
    
    // fallback for API failures
    function onFail(responseCode, data, context) {
    	System.println("ResponseCode: " + responseCode + " on " + context);
    	var msg = "Error code: " + responseCode + "\n";
    	msg += d_api.respCodeToString(responseCode) + "\n";
    	msg += "context: " + context;
    	Media.notifySyncComplete(responseCode.toString());
    }
    
}
