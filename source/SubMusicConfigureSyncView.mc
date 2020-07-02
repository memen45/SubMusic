using Toybox.WatchUi;
using Toybox.Communications;

// This is the View that is used to configure the songs
// to sync. New pages may be pushed as needed to complete
// the configuration.
class SubMusicConfigureSyncView extends WatchUi.View {

	private var d_playlists;
	private var d_menushown = false;
	private var d_provider;

    function initialize(provider) {
        View.initialize();
        
        d_provider = provider;
        d_provider.setFallback(method(:onFail));
    }

    // Load your resources here
    function onLayout(dc) {
        // setLayout(Rez.Layouts.ConfigureSyncLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    
    	if (!d_menushown) {
    		System.println("Will send API request now");
    		d_provider.getAllPlaylists(method(:onGetAllPlaylists));
    		return;
    	}
		d_menushown = false;
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        // View.onUpdate(dc);
        
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        // Indicate that the songs are being fetched
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, WatchUi.loadResource(Rez.Strings.fetchingPlaylists), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    
    }

	// handles the response on getplaylists API request
	function onGetAllPlaylists(playlists) {
		d_playlists = playlists;
		pushSyncMenu();
		WatchUi.requestUpdate();
	}
	
	// creates the sync menu with the playlists from the server
	function pushSyncMenu() {
        var prechecked = {};
        
        var liststore = new SubMusicPlaylistStore();
        
        // precheck local and tosync playlists
        var ids = liststore.getLocalIds();
        ids.addAll(liststore.getToSyncIds());
        for (var idx = 0; idx < ids.size(); ++idx) {
        	prechecked[ids[idx]] = true;
        }
        
        // uncheck the todelete lists
        ids = liststore.getToDeleteIds();
        for (var idx = 0; idx < ids.size(); ++idx) {
        	prechecked.remove(ids[idx]);
        }

        // Create the menu, prechecking anything that is to be or has been synced
		var menu = new WatchUi.CheckboxMenu({:title => Rez.Strings.syncMenuTitle});
        for (var idx = 0; idx < d_playlists.size(); ++idx) {
            var item = new WatchUi.CheckboxMenuItem(d_playlists[idx]["name"],
                                                    d_playlists[idx]["songCount"].toString() + " songs",
                                                    d_playlists[idx]["id"],
                                                    prechecked.hasKey(d_playlists[idx]["id"]),
                                                    {});
            menu.addItem(item);
        }
        WatchUi.pushView(menu, new SubMusicConfigureSyncDelegate(d_playlists), WatchUi.SLIDE_IMMEDIATE);
        d_menushown = true;
    }
    
    function onFail(responseCode, data) {
    	var title = "Error: " + responseCode;
    	var detail = respCodeToString(responseCode) + "\n";
    	if (data != null) {
    		detail += data["errorMessage"];
    	}
		WatchUi.switchToView(new ErrorView(title, detail), null, WatchUi.SLIDE_IMMEDIATE);
		d_menushown = true;
		WatchUi.requestUpdate();
	}
    
	// move to somewhere else later, but now this is one of the two places where it is used
    function respCodeToString(responseCode) {
    	if (responseCode == Communications.INVALID_HTTP_HEADER_FIELDS_IN_REQUEST) {
    		return "\"INVALID_HTTP_HEADER_FIELDS_IN_REQUEST\"";
    	} else if (responseCode == Communications.INVALID_HTTP_BODY_IN_REQUEST) {
    		return "\"INVALID_HTTP_BODY_IN_REQUEST\"";
    	} else if (responseCode == Communications.INVALID_HTTP_METHOD_IN_REQUEST) {
    		return "\"INVALID_HTTP_METHOD_IN_REQUEST\"";
    	} else if (responseCode == Communications.NETWORK_REQUEST_TIMED_OUT) {
    		return "\"NETWORK_REQUEST_TIMED_OUT\"";
    	} else if (responseCode == Communications.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE) {
    		return "\"INVALID_HTTP_BODY_IN_NETWORK_RESPONSE\"";
    	} else if (responseCode == Communications.INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE) {
    		return "\"INVALID_HTTP_HEADER_FIELDS_IN_NETWORK_RESPONSE\"";
    	} else if (responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE) {
    		return "\"NETWORK_RESPONSE_TOO_LARGE\"";
    	} else if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY) {
    		return "\"NETWORK_RESPONSE_OUT_OF_MEMORY\"";
    	} else if (responseCode == Communications.STORAGE_FULL) {
    		return "\"STORAGE_FULL\"";
    	} else if (responseCode == Communications.SECURE_CONNECTION_REQUIRED) {
    		return "\"SECURE_CONNECTION_REQUIRED\"";
    	}
    	return "Unknown";
    }
}
