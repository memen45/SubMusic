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
				Menu2.initialize({:title => menu.title()});
	        	
			   	d_menu = menu;
		    }
		    
		    // update the created menu with new values
		    function updateMenu() {
				// set title
				setTitle(d_menu.title());

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
				setTitle(d_menu.title());

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
		    
		    function onShow() {

				// create if not created
				if (!d_created) {
					createMenu();
					return;
				}

				// update otherwise
				updateMenu();
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

		class MenuBase {
			private var d_title;
			private var d_loaded;
			private var f_loaded = null;
			private var d_error = null;

			function initialize(title, loaded) {
				d_title = title;
				d_loaded = loaded;
			}

			function loaded() {
				return d_loaded;
			}

			function title() {
				return d_title;
			}

			function error() {
				return d_error;
			}

			function setOnLoaded(callback) {
				System.println("MenuBase::setOnLoaded");
				f_loaded = callback;
			}

			function onLoaded(error) {
				System.println("MenuBase::onLoaded");
				
				d_error = error;
				d_loaded = true;
				if (f_loaded) { f_loaded.invoke(error); }
			}

			function placeholder() {
				if (d_loaded) {
					return Rez.Strings.placeholder_noMenuItems;
				}
				return Rez.Strings.placeholder_loading;
			}

		}

		// helper class for menus that require loading and can error
		// loaded menus can use a simple MenuView
		class MenuLoader {

			private var d_menu = null;
			private var d_delegate = null;

			function initialize(menu, delegate) {
				System.println("MenuLoader::initialize(" + WatchUi.loadResource(menu.title()) + ")");

				// store variables if needed for non-loaded menu
				if (!menu.loaded()) {
					// reference the menu and delegate for onLoaded
					d_menu = menu;
					d_delegate = delegate;	

					menu.setOnLoaded(method(:onLoaded));
				}

				// for loaded menus: check error
				var error = menu.error();
				if (error) {
					WatchUi.pushView(new ErrorView(error), null, WatchUi.SLIDE_IMMEDIATE);
					return;
				}

				// for empty menus, use placeholder
				if (menu.getItem(0) == null) {	
					WatchUi.pushView(new TextView(menu.placeholder()), null, WatchUi.SLIDE_IMMEDIATE);
					return;
				}

				// load the menu
				WatchUi.pushView(new MenuView(menu), delegate, WatchUi.SLIDE_IMMEDIATE);
				return;
			}

			function onLoaded(error) {
				System.println("MenuLoader::onLoaded( " + (error instanceof SubMusic.Error) + ")");
				// switch to error view on error
				if (error instanceof SubMusic.Error) {
					WatchUi.switchToView(new ErrorView(error), null, WatchUi.SLIDE_IMMEDIATE);
					return;
				}

				// only show menu if there are items to show
				if (d_menu.getItem(0) == null) {
					WatchUi.switchToView(new TextView(d_menu.placeholder()), null, WatchUi.SLIDE_IMMEDIATE);
				} else {
					WatchUi.switchToView(new MenuView(d_menu), d_delegate, WatchUi.SLIDE_IMMEDIATE);
				}

				// allow garbage collection / reference count to zero
				d_menu = null;
				d_delegate = null;
			}
		}
	}
}
