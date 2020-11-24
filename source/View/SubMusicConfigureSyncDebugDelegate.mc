using Toybox.WatchUi;
using Toybox.Media;

class SubMusicConfigureSyncDebugDelegate extends WatchUi.Menu2InputDelegate {

	private var d_provider;

	function initialize(provider) {
		Menu2InputDelegate.initialize();
		
		d_provider = provider;
	}
    
	function onSelect(item) {
		var id = item.getId();
		
		if (SyncDebugMenu.TEST_SERVER == id) {
			WatchUi.pushView(new SubMusicTestView(d_provider), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncDebugMenu.PLAYLIST_DETAIL == id) {
			var ids = PlaylistStore.getIds();
			var storage = PlaylistStore.get(ids[0]);	// disconnected playlist, viewing only
			WatchUi.pushView(new SubMusicPlaylistView(new Playlist(storage)), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return;
	}

}
