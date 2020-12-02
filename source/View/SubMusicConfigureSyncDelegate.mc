using Toybox.WatchUi;

class SubMusicConfigureSyncDelegate extends WatchUi.Menu2InputDelegate {

	private var d_syncauto;		// set true if called from watch (sync will start w ith popview), false if called from anywhere else

	function initialize(syncauto) {
		Menu2InputDelegate.initialize();
		
		d_syncauto = syncauto;
	}
    
	function onSelect(item) {
		var id = item.getId();
		
		if (SyncMenu.SELECT_PLAYLISTS == id) {
			WatchUi.pushView(new SubMusicConfigureSyncPlaylistView(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncMenu.DEBUG_INFO == id) {
			WatchUi.pushView(new SubMusicConfigureSyncDebugView(), new SubMusicConfigureSyncDebugDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		
		if ((SyncMenu.START_SYNC == id) && !d_syncauto) {
			Communications.startSync();
		}
		
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return;
	}

}
