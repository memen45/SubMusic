using Toybox.WatchUi;

class SubMusicServerView extends WatchUi.View {
	
	private var d_textarea;
	
	function initialize() {
		View.initialize();
	}

    function onLayout(dc) {
    	var settings = SubMusic.Provider.getProviderSettings();
    	var msg = "";
    	if (settings["api_typ"] == ApiStandard.AMPACHE) {
    		msg += "Ampache";
    	} else {
    		msg += "Subsonic";
    	}
    	msg += "\n" + settings["api_url"];
    	msg += "\n" + settings["api_usr"];
    	
    	d_textarea = new WatchUi.TextArea({
    		:text => msg,
    		:color => Graphics.COLOR_WHITE,
    		:font => [ Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY ],
    		:justification => Graphics.TEXT_JUSTIFY_CENTER,
    		:locX => WatchUi.LAYOUT_HALIGN_CENTER,
    		:locY => WatchUi.LAYOUT_VALIGN_CENTER,
            :width=> dc.getWidth() * 2 / 3,
            :height=> dc.getHeight() * 2 / 3,
    	});
    }
    	

    // Update the View
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        d_textarea.draw(dc);
    }
	
}
		