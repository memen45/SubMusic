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
	
			function initialize(menu) {
				Menu2.initialize({:title => menu.title});
	        	
	        	var items = menu.items.keys().size();
	        	for (var idx = 0; idx != items; ++idx) {
	        		addItem(new WatchUi.MenuItem(
			        	menu.items[idx][LABEL],		// label
			        	menu.items[idx][SUBLABEL],	// sublabel
			        	menu.items[idx][METHOD],	// identifier (use method for simple callback)
			        	null						// options
			        ));
			   	}
		    }
		
		}
		
		class Delegate extends WatchUi.Menu2InputDelegate {
		
			function initialize() {
				Menu2InputDelegate.initialize();
			}
		
			function onSelect(item) {
				item.getId().invoke();
			}
			
			// optional: function onBack() to close the menu properly
		}
		
	}
}
