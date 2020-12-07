using Toybox.WatchUi;
using Toybox.Communications;

class SubMusicConfigureSyncDebugDelegate extends WatchUi.Menu2InputDelegate {

	private var d_provider = SubMusic.Provider.get();

	function initialize() {
		Menu2InputDelegate.initialize();
	}
    
	function onSelect(item) {
		var id = item.getId();
		
		if (SyncDebugMenu.TEST_SERVER == id) {
			WatchUi.pushView(new SubMusicTestView(d_provider), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncDebugMenu.DONATE == id) {
			onDonate();
			WatchUi.pushView( new TextView("Open https://www.paypal.com/donate?hosted_button_id=HBUU64LT3QWA4 on your phone"), new TapDelegate(method(:onDonate)), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncDebugMenu.PLAYLIST_DETAIL == id) {
			var ids = PlaylistStore.getIds();
			var storage = PlaylistStore.get(ids[0]);	// disconnected playlist, viewing only
			WatchUi.pushView(new SubMusicPlaylistView(new Playlist(storage)), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncDebugMenu.SERVER_DETAIL == id) {
			WatchUi.pushView(new SubMusicServerView(), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncDebugMenu.REMOVE_ALL == id) {
			var msg = "Are you sure you want to delete all Application data?";
			WatchUi.pushView(new WatchUi.Confirmation(msg), new SubMusicConfirmationDelegate(self.method(:onRemoveAll)), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return;
	}
	
	function onDonate() {
		var url = "https://www.paypal.com/donate";
		var params = { "hosted_button_id" => "HBUU64LT3QWA4", };
		Communications.openWebPage(url, params, null);
	}
	
	function onRemoveAll() {
		// collect all ids of songs
		var ids = SongStore.getIds();
		for (var idx = 0; idx != ids.size(); ++idx) {
			var id = ids[idx];
			var isong = new ISong(id);
			isong.setRefId(null);			// delete from cache
			isong.remove();					// remove from Store
		}
		
		// remove all metadata
		Application.Storage.clearValues();
		
		// check storage to set the storage version number
		Storage.check();
	}

}
