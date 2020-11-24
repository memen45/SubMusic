using Toybox.WatchUi;
using Toybox.Media;

class SubMusicConfigureSyncDelegate extends WatchUi.Menu2InputDelegate {

	private var d_provider;

	function initialize(provider) {
		Menu2InputDelegate.initialize();
		
		d_provider = provider;
	}
    
	function onSelect(item) {
		var id = item.getId();
		
		if (SyncMenu.SELECT_PLAYLISTS == id) {
			WatchUi.pushView(new SubMusicConfigureSyncPlaylistView(d_provider), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncMenu.START_SYNC == id) {
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncMenu.DEBUG_INFO == id) {
			WatchUi.pushView(new SubMusicConfigureSyncDebugView(), new SubMusicConfigureSyncDebugDelegate(d_provider), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return;
	}

}
