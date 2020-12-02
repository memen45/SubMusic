using Toybox.WatchUi;

class SubMusicConfigurePlaybackDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    function onSelect() {
        // tap on the empty screen opens the sync menu
        var view = new SubMusicConfigureSyncView();
        var delegate = new SubMusicConfigureSyncDelegate(false);
      	WatchUi.switchToView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
    
    function onBack() {
    	WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

}
