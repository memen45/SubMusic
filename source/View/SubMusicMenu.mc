using Toybox.WatchUi;

/* 
Planned menu:

Library
  - Now Playing
   - Song 1
  - Play All Songs
  - Playlists
   - Playlist 1
     - Play Now
     - Podcast Mode (toggle)
  - Podcasts
   - Podcast 1
     - Play Now
     - Podcast Mode (toggle)
     - Episodes
      - Episode 1
       - Play Now
     
  - Sync Settings
    - Sync Now
    - Playlists
    - (Podcasts)
    - Server
      - Server Info
      - Test Server
    - About/
 - About
  - SubMusic Version
  - Donate

Pretty (https://tree.nathanfriend.io/?s=(%27options!(%27fancy!true~fullPath!false~trailingSlash!true)~H(%27H%27LibraryGNow%204ing62SongCG4%20AllOongsG9s6290G5s62506Bs*3BC*F.47*FGSyncOettingsJSync7J9sJ%7B5s%7DJ8*3.8%20Info*3.Test%208JAbout%2FK%202AboutGSubMusic%20VQsionGDonate%27)~vQsion!%271%27)*K3.320C6.476.5%20Mode%20%7Btoggle%7D2-%20F%204Play5Podcast6*%207%20Now8SQvQ94listB.EpisodeC%201F3%20G*2Hsource!J*.K%5CnO%20SQer%01QOKJHGFCB987654320.*): 
.
└── Library/
    ├── Now Playing/
    │   └── Song 1
    ├── Play All Songs
    ├── Playlists/
    │   └── Playlist 1/
    │       ├── Play Now
    │       └── Podcast Mode (toggle)
    ├── Podcasts/
    │   └── Podcast 1/
    │       ├── Play Now
    │       ├── Podcast Mode (toggle)
    │       └── Episodes/
    │           └── Episode 1/
    │               └── Play Now
    ├── Sync Settings/
    │   ├── Sync Now
    │   ├── Playlists
    │   ├── (Podcasts)
    │   ├── Server/
    │   │   ├── Server Info
    │   │   └── Test Server
    │   └── About/
    └── About/
        ├── SubMusic Version
        └── Donate
*/

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
	
			/* menu should have the following members
			 * var title 				- containing the title of the menu
			 * function getItem(idx) 	- returning the menuItem for idx 
			 * function loaded()		- returns true if menu elements are ready, false otherwise
			 * 
			 * if loaded can return false, the following members should also be available
			 * function placeholder()	- returns string to show in TextView while the menu is loading
			 * function setOnLoaded(callback)	- sets :onLoaded as the callback function
			 */
			function initialize(menu) {
				Menu2.initialize({:title => menu.title});
	        	
			   	d_menu = menu;
		    }
		    
		    // update the created menu with new values
		    function updateMenu() {
				// set title
				setTitle(d_menu.title);

				// load the items
				var idx = 0;
				var item = d_menu.getItem(idx);
				while (item != null) {
					updateItem(item, idx);

					// load next item
					idx += 1;
					item = d_menu.getItem(idx);
				}
			}
			
			// create the menu by adding the items
			function createMenu() {
				// set title
				setTitle(d_menu.title);

				// load the items
				var idx = 0;
				var item = d_menu.getItem(idx);
				while (item != null) {
					addItem(item);

					// load next item
					idx += 1;
					item = d_menu.getItem(idx);
				}

				// mark as created
		    	d_created = true;
			}
		    
		    // returns a WatchUi.MenuItem from object
		    // function makeMenuItem(item) {
		    // 	return new WatchUi.MenuItem(
			//     		item[LABEL],		// label
			//         	item[SUBLABEL],		// sublabel
			//         	item[METHOD],		// identifier (use method for simple callback)
			//         	null				// options
			//     );
			// }
		    
		    function onShow() {

				// show placeholder if not loaded yet
				if (!d_menu.loaded()) {
					d_menu.setOnLoaded(method(:onLoaded)); // subscribe to loaded complete
					WatchUi.pushView(new TextView(d_menu.placeholder()), null, WatchUi.SLIDE_IMMEDIATE);
					return;
				}

				// create if not created
				if (!d_created) {
					createMenu();
					return;
				}

				// update otherwise
				updateMenu();
		    }

			function onLoaded() {
				// if it is now loaded, show the menu, pop the placeholder
				WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
			}
		
		}
		
		class MenuDelegate extends WatchUi.Menu2InputDelegate {
		
			private var d_callback;		// callback function
			private var d_callOnBack; 	// callback on Back
		
			function initialize(callback, callOnBack) {
				Menu2InputDelegate.initialize();
				
				d_callback = callback;
				d_callOnBack = callOnBack;
			}
		
			function onSelect(item) {

				// execute immendiately if executable
				var id = item.getId();
				if (id instanceof Lang.Method) {
					id.invoke();
					return;
				}

				// pass complete item to default callback
				d_callback.invoke(item);
			}
			
			function onBack() {
				if (d_callOnBack) { d_callOnBack.invoke(); }
				else { Menu2InputDelegate.onBack(); }
			}
		}
		
	}
}
