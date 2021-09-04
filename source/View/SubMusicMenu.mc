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
     - Shuffle
     - Podcast Mode (toggle)
     - Songs
     - Remove on next sync (confirm)
  - Podcasts
   - Podcast 1
     - Play Now
     - Episodes
      - Episode 1
       - Play Now
     - Remove on next sync (confirm)
  - Sync Settings
    - Browse
      - Playlists
        - <playlist1>
          - [] Offline available
          - Songs
      - Podcasts
        - <podcast1>
          - [] Offline available (latest only)
          - Episodes
            - <episode1>
        - ...
      - Radiostations
        - <radiostation1>
          - Play now ?
    - Sync Now
    - Server
      - Server Info
      - Test Server
    - About/
 - About
  - SubMusic Version
  - Server Version
  - Donate
  - Settings
    - Disable 30s skip
    - Remove cached metadata
    - Remove all data

Pretty: https://tree.nathanfriend.io/?s=(%27optiKs!(%27fancy!true~fullPath!false~trailingSlash!true)~q(%27q%27Library_Now%207ing26j%201_7%20All%20js_7Xs267XWShuffle2*6P8%20Mod9%7Btoggle%7D2*6js_P8s26P8WEHesxEH91567C4Sync%20ZBrowsex7XUplayXJz%5B%5D%20Ge5zjsxP8Up8JzG9%7Blatest%20Kly%7D5zEHes5*z%3CeHeJF...xRYUrYJz7%20now%20%3F2FSyncCFQxQ%20InfoxTest%20Q2FAbout%2F%5Cn6About_SubMusic%20VersiK_DKate_ZDisabl930s%20skip2FRemov9all%20data%27)~versiK!%271%27)*%20%202%5CnF-%2052**6%2047Play8odcast9e%20C%20Now2F*4GOfflin9availablHpisodJ1%3E5KonQServerUs5F%3CW%2012*67C*6XlistYadiostatiKZSettings2F_24jSKgqsource!x54z*F%01zxqj_ZYXWUQKJHGFC9876542*
.
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
    │       ├── Songs
    │       └── Remove on next sync (confirm)
    ├── Podcasts/
    │   └── Podcast 1/
    │       ├── Play Now
    │       ├── Episodes/
    │       │   └── Episode 1/
    │       │       └── Play Now
    │       └── Remove on next sync (confirm)
    ├── Sync Settings/
    │   ├── Browse/
    │   │   ├── Playlists/
    │   │   │   └── <playlist1>/
    │   │   │       ├── [] Offline available
    │   │   │       └── Songs
    │   │   ├── Podcasts/
    │   │   │   ├── <podcast1>/
    │   │   │   │   ├── [] Offline available (latest only)
    │   │   │   │   └── Episodes/
    │   │   │   │       └── <episode1>
    │   │   │   └── ...
    │   │   └── Radiostations/
    │   │       └── <radiostation1>/
    │   │           └── Play now ?
    │   ├── Sync Now
    │   ├── Server/
    │   │   ├── Server Info
    │   │   └── Test Server
    │   └── About/
    └── About/
        ├── SubMusic Version
        ├── Server Version
        ├── Donate
        └── Settings/
            ├── Disable 30s skip
            ├── Remove cached metadata
            └── Remove all data
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
				if (d_callback) {
					d_callback.invoke(item);
				}
			}
			
			function onBack() {
				var handled = false;
				if (d_callOnBack) { handled = d_callOnBack.invoke(); }
				// else { Menu2InputDelegate.onBack(); }
				if (!handled) { return Menu2InputDelegate.onBack(); }
				return true;
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

			// default item loader, returns null if menu idx not found
			function getItem(idx) {
				System.println("SubMusicMenu::getItem( idx: " + idx + " ) - " + d_title);
				
				// check if item exists
				if (idx >= d_items.size()) {
					return null;
				}
				var item = d_items[idx];

				// support dynamically computed strings
				var labl = item.get(LABEL);
				if (labl instanceof Lang.Method) {
					labl = labl.invoke();
				}
				var sublabl = item.get(SUBLABEL);
				if ((sublabl != null) 
					&& (sublabl instanceof Lang.Method)) {
					sublabl = sublabl.invoke();
				}
				var method = item.get(METHOD);

				// create the menu item itself
				return new WatchUi.MenuItem(
					labl,			// label
					sublabl,		// sublabel
					method,			// identifier (use method for simple callback)
					null			// options
			    );
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
				// d_loaded = true;		// make sure menus are reloaded, keep false
				if (f_loaded) { f_loaded.invoke(error); }
			}

			function placeholder() {
				if (d_loaded) {
					return WatchUi.loadResource(Rez.Strings.placeholder_noMenuItems);
				}
				return WatchUi.loadResource(Rez.Strings.placeholder_loading);
			}

			// transition from menu item to menu view
			function onOpen() {
				var loader = new MenuLoader(self, delegate());
			}

			// default menu delegate
			function delegate() {
				return new MenuDelegate(null, null);
			}

			// Determines how the MenuItem will look
			function get(key) {
				if (key == LABEL) {
					return label();
				} else if (key == SUBLABEL) {
					return sublabel();
				} else if (key == METHOD) {
					return method(:onOpen);
				}
				return null;
			}

			function label() {
				return d_title;
			}

			function sublabel() {
				return null;
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

					// set the callback and start loading
					menu.setOnLoaded(method(:onLoaded));
					menu.load();
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
				System.println("MenuLoader::onLoaded( Error: " + (error instanceof SubMusic.Error) + ")");
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
