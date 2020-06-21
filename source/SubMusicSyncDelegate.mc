using Toybox.Application;
using Toybox.Communications;
using Toybox.Media;

// Performs the sync with the music provider
class SubMusicSyncDelegate extends Media.SyncDelegate {

    // playlists to sync
    private var d_todo;
    
    // songs to sync or remove
    private var d_liststore;
    
    // track the total of songs synced
    private var d_songs_total;
    private var d_songs_count = 0;
    
    // api access
    private var d_provider;
    

    // Constructor
    function initialize(provider) {
        SyncDelegate.initialize();
        
        d_provider = provider;
        d_provider.setFallback(method(:onFail));
        
        d_liststore = new SubMusicPlaylistSync();
    }

    // Starts the sync with the system
    function onStartSync() {
        System.println("Sync started...");
        
        d_songs_total = d_liststore.countSongs();
        
        // Step 1: Delete songs from locally removed playlists		-		syncNextPlaylistDelete();
        // Step 2: Synchronize local playlists with remote server 	+/-		syncNextPlaylistLocal();
        // Step 3: Synchronize added playlists with remote server 	+		syncNextPlaylistSync();
        // Step 4: Delete songs from local storage					-		deleteSongs();
        // Step 5: Download songs from server to local storage		+		syncNextSong();
        syncNextPlaylistDelete();
    }
    
    /**
     * syncNextPlaylistDelete
     * 
     * remove all songs from a playlist
     */
     function syncNextPlaylistDelete() {
     	System.println("To Delete Playlists:  " + d_liststore.getToDeleteIds().size());
     	
     	var count = d_liststore.delete();
     	onSongSynced(count);
     	
     	// create todo list (playlist ids)
     	d_todo = d_liststore.getLocalIds();
     	d_todo.addAll(d_liststore.getToSyncIds());
     	
     	syncNextPlaylist();
     }
    
    /**
     * syncNextPlaylistLocal
     * 
     * request all songs in local lists and add/remove extra's or missing
     */
	function syncNextPlaylist() {
		System.println("To Update Playlists: " + d_todo.size());
		
     	if (d_todo.size() != 0) {
     		System.println("Syncing a local playlist with id: " + d_todo[0]);
     		d_provider.getPlaylist(d_todo[0], method(:onNextPlaylist));
     		return;
     	}
     	
     	// if nothing more to do, flush pending deletes, start downloading songs
		var count = d_liststore.flushDelete();
		
		// report progress
		onSongSynced(count);
		System.println("Deleted: " + count + " songs from local storage");
		
		// create todo list (song ids)
		d_todo = d_liststore.getSongsToSyncIds();
		
		// update fallback
		d_provider.setFallback(method(:onSongDownloadFail));
		syncNextSong();
    }
    
    function onNextPlaylist(playlist) {
    	// update playlist and counts
    	var count = d_liststore.update(playlist);
    	d_songs_total = d_liststore.countSyncs();
    	
    	// report progress
    	onSongSynced(count);
    	System.println("Synced a local playlist: " + playlist["name"]);
    	
    	// slice first element from todo list
    	d_todo.remove(d_todo[0]);
    	syncNextPlaylist();
    }

	// Downloads the next song to be synced
	function syncNextSong() {
		
		System.println("To update songs: " + d_todo.size());
		
		// if todo empty, nothing to do
		if (d_todo.size() == 0) {
    		Media.notifySyncComplete(null);
    		return;
    	}
    	
		System.println("Syncing song " + d_todo[0] + " number " + d_songs_count + " of " + d_songs_total);
		
		// make the request
		d_provider.stream(d_todo[0], "mp3", method(:onSongDownloaded));
    }

    // Callback for when a song is downloaded
	function onSongDownloaded(refId) {
		d_liststore.storeSong(d_todo[0], refId);
		
		onSongSynced(1);
		System.println("Synced song " + d_todo[0]);
    	
    	// remove first element from todo list
    	d_todo.remove(d_todo[0]);
    	syncNextSong();
    }
    
    // fallback for failed download
	function onSongDownloadFail(responseCode, data) {
		onSongSynced(1);
		System.println("Sync failed " + d_todo[0]);
    	
    	// slice first element from todo list
    	d_todo.remove(d_todo[0]);
    	syncNextSong();
    }

    // Update the system with the current sync progress
    function onSongSynced(count) {
    	d_songs_count += count;
    	
    	var count = d_songs_count - 1;
    	var progress = (100 * count) / d_songs_total.toFloat();
    	progress = progress.toNumber();
    	
    	Media.notifySyncProgress(progress);
    }
    
    // fallback for API failures
    function onFail(responseCode, data) {
    	System.println("ResponseCode: " + responseCode + " payload " + data);
    	var msg = "Error code: " + responseCode + "\n";
    	msg += d_provider.respCodeToString(responseCode) + "\n";
    	Media.notifySyncComplete(responseCode.toString());
    }

    // Sync always needed to verify new songs on the server
    function isSyncNeeded() {
        return true;
    }
}
