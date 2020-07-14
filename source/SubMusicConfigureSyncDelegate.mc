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
		
		if (SyncMenu.PLAYLISTS == id) {
			WatchUi.pushView(new SubMusicConfigureSyncPlaylistView(d_provider), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncMenu.TEST == id) {
			WatchUi.pushView(new SubMusicConfigureSyncTestView(d_provider), new WatchUi.BehaviorDelegate(), WatchUi.SLIDE_IMMEDIATE);
			return;
		}
		if (SyncMenu.START_SYNC == id) {
			Media.startSync();
			return;
		}
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		return;
	}

}
