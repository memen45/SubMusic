using Toybox.WatchUi;

module SubMusic {
	module Menu {
	
		// define keys for the menu parameters
		enum {
			LABEL,
			SUBLABEL,
			METHOD,
		}
	
		class MenuView extends WatchUi.Menu2 {
		
			private var d_menu;
			private var d_created = false; // menu not created yet
	
			function initialize(menu) {
				Menu2.initialize({:title => menu.title});
	        	
			   	d_menu = menu;
		    }
		    
		    // update the created menu with new values
		    function updateMenu(items) {
		    	for (var idx = 0; idx != items.keys().size(); ++idx) {
	        		updateItem(makeMenuItem(items[idx]), idx);
			   	}
			}
			
			// create the menu by adding the items
			function createMenu(items) {
				for (var idx = 0; idx != items.keys().size(); ++idx) {
	        		addItem(makeMenuItem(items[idx]));
			   	}
			}
		    
		    // returns a WatchUi.MenuItem from object
		    function makeMenuItem(item) {
		    	return new WatchUi.MenuItem(
			    		item[LABEL],		// label
			        	item[SUBLABEL],		// sublabel
			        	item[METHOD],		// identifier (use method for simple callback)
			        	null				// options
			    );
			}
		    
		    function onShow() {
		    	
		    	var items = d_menu.getItems();
		    	if (d_created) {
		    		System.println("MenuView::onShow(update)");
		    		setTitle(d_menu.title);
		    		updateMenu(items);
		    		return;
		    	}
		    	
		    	// create menu and indicate created
		    	System.println("MenuView::onShow(create)");
		    	createMenu(items);
		    	d_created = true;
		    }
		
		}
		
		class Delegate extends WatchUi.Menu2InputDelegate {
		
			private var d_callback; // callback on Back
		
			function initialize(callback) {
				Menu2InputDelegate.initialize();
				
				d_callback = callback;
			}
		
			function onSelect(item) {
				item.getId().invoke();
			}
			
			function onBack() {
				if (d_callback) { d_callback.invoke(); }
				else { Menu2InputDelegate.onBack(); }
			}
		}
		
	}
}
