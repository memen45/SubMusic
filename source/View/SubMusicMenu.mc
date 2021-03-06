using Toybox.WatchUi;

/* 
Planned menu:

LLibrary
  - Now Playing
   - Song 1
  - Play All Songs
  - Playlists
   - Playlist 1
     - Play Now
     - Shuffle
     - Podcast Mode (toggle)
     - Songs
  - Podcasts
   - Podcast 1
     - Play Now
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
  - Settings
    - Disable 30s skip

Pretty: https://tree.nathanfriend.io/?s=(%27optiRs!(%27fancy!true~fullPath!false~trailingSlash!true)~H(%27H%27LibraryQNow%205ing42SRgBQ5%20All%20_Fs42FOShuffleZ6%20ModU%7Btoggle%7DZ_6s426OJs48JB4%20857QSynWKSync7YFsY%7B6s%7DY9489%20Info48Test%209YAbout%2FG2AboutQSubMusiWVXsiRQDRateQKDisablU30s%20skip%27)~vXsiR!%271%27)*G8%20%2022-%204*%205Play6Podcast7%20Now8%20.9SXvXB%201Cngs*F5listG%5Cn%20Hsource!JEpisodeKSettiC.OBZ57ZQ*2RonUe%20Wc%20XerY*.Z4._SoC2%01_ZYXWURQOKJHGFCB9876542.*
.
└── Library/
    ├── Now Playing/
    │   └── Song 1
    ├── Play All Songs
    ├── Playlists/
    │   └── Playlist 1/
    │       ├── Play Now
    │       ├── Shuffle
    │       ├── Podcast Mode (toggle)
    │       └── Songs
    ├── Podcasts/
    │   └── Podcast 1/
    │       ├── Play Now
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
        ├── Donate
        └── Settings/
            └── Disable 30s skip
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
					return WatchUi.loadResource(Rez.Strings.placeholder_noMenuItems);
				}
				return WatchUi.loadResource(Rez.Strings.placeholder_loading);
			}

		}

		// helper class for menus that require loading and can error
		// loaded menus can use a simple MenuView
		class MenuLoader {

			private var d_menu = null;
			private var d_delegate = null;

			function initialize(menu, delegate) {
				var title = menu.title();
				if (!(menu.title() instanceof Lang.String)) {
					title = WatchUi.loadResource(title);
				}
				System.println("MenuLoader::initialize(" + title + ")");

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
