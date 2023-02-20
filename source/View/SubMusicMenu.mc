using Toybox.WatchUi;
using Toybox.Graphics;

/* 
Planned menu:

Library
  - Now Playing
   - <Song 1>
  - Play All Songs
  - Playlists
   - <Playlist 1>
     - Play Now
     - Shuffle
     - Podcast Mode (toggle)
     - Songs
     - Remove on next sync (confirm)
  - Podcasts
   - <Podcast 1>
     - Play Now
     - Episodes
      - <Episode 1>
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
    - Settings/
- Settings
 - App settings
  - Disable 30s skip
 - Storage
  - Memory
  - Media Cache
  - Remove all data
 - SubMusic Version
 - Donate

Pretty: https://tree.nathanfriend.io/?s=(%27optiUs!(%27fancy!true~fullPath!false~trailingSlash!true)~source!(%27source!%27Library24Now%209ingzSUg%20J249%20All%20SUgs249listsz9liFShuffle2*6PXsWModK%7Btoggle%7D2*6SUgs5PXstszPXFEYes84%3CEYKJ869Z5Sync%20SG2QBrowse849listjplayli78*QSUgs84PXstjpX7%20%7BlatesWUly%7D8*QEYes8**Q%3CeYeJ8Q...84RqjrqJ8*Q9%20now%20%3F2QSyncZ2Q_84_%20Info84TesW_2QSG%2FH4SGH6App%20sG24DisablK30s%20skipH6Storage24Memory24Media%20Cache24RemovKall%20dataH6SubMusic%20VersiUH6DUate%27)~versiU!%271%27)*%20%202HQ-%2052*6RemovKU%20nexWsync%20%7BcUfirm%7D246%2047stJ8*Q%5B%5D%20OfflinKavailable82**9PlayFsWJ2*69Z2*6GettingsH%5CnJ1%3EKe%20Q*4UonWt%20XodcaYpisodZ%20Now_Serverjs8Q%3CqadiostatiUz26%3C%01zqj_ZYXWUQKJHGF9876542*

.
├── Library/
│   ├── Now Playing/
│   │   └── <Song 1>
│   ├── Play All Songs
│   ├── Playlists/
│   │   └── <Playlist 1>/
│   │       ├── Play Now
│   │       ├── Shuffle
│   │       ├── Podcast Mode (toggle)
│   │       ├── Songs
│   │       └── Remove on next sync (confirm)
│   ├── Podcasts/
│   │   └── <Podcast 1>/
│   │       ├── Play Now
│   │       ├── Episodes/
│   │       │   └── <Episode 1>/
│   │       │       └── Play Now
│   │       └── Remove on next sync (confirm)
│   └── Sync Settings/
│       ├── Browse/
│       │   ├── Playlists/
│       │   │   └── <playlist1>/
│       │   │       ├── [] Offline available
│       │   │       └── Songs
│       │   ├── Podcasts/
│       │   │   ├── <podcast1>/
│       │   │   │   ├── [] Offline available (latest only)
│       │   │   │   └── Episodes/
│       │   │   │       └── <episode1>
│       │   │   └── ...
│       │   └── Radiostations/
│       │       └── <radiostation1>/
│       │           └── Play now ?
│       ├── Sync Now
│       ├── Server/
│       │   ├── Server Info
│       │   └── Test Server
│       └── Settings/
└── Settings/
    ├── App settings/
    │   └── Disable 30s skip
    ├── Storage/
    │   ├── Memory
    │   ├── Media Cache
    │   └── Remove all data
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
			OPTION,			// if Boolean: ToggleMenuItem, if Drawable: IconMenuItem
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
				if ($.debug) {
					System.println("MenuView::updateMenu " + d_menu.title() );
				}

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

			function onHide() {
				if (!d_menu.loaded()) {
					if ($.debug) {
						System.println("MenuView::onHide -> will unload the menu " + d_menu.title());
					}
					d_menu.unload();
				}
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
				if (handled != true) { return Menu2InputDelegate.onBack(); }
				return true;
			}
		}

		class MenuBase {
			private var d_title;
			private var d_loaded;
			private var f_loaded = null;
			private var d_error = null;

			private var d_items = [];

			function initialize(title, loaded) {
				// try and load the resource
				if (!(title instanceof Lang.String)) {
					title = WatchUi.loadResource(title);
				}
				// if ($.debug) {
				// 	System.println("MenuBase::initialize( title: " + title + " )");
				// }
				d_title = title;
				d_loaded = loaded;
			}

			function items() {
				return d_items;
			}

			function load(items) {
				d_items = items;
				
				// mark as loaded
				setLoaded(true);
				return loaded();
			}

			// default unloader, make sure resources are freed and menu will be reloaded
			function unload() {
				d_items = [];
				d_loaded = false;
			}

			function loaded() {
				return d_loaded;
			}

			function title() {
				return d_title;
			}

			// if method, invoke it, otherwise return original
			function resolve_var(value) {
				if (value instanceof Lang.Method) {
					return value.invoke();
				}
				return value;
			}

			// default item loader, returns null if menu idx not found
			function getItem(idx) {
				// if ($.debug) {
				// 	System.println("SubMusicMenu::getItem( idx: " + idx + " ) - " + d_title);
				// }
				
				// check if item exists
				if (idx >= d_items.size()) {
					return null;
				}
				var item = d_items[idx];

				// support dynamically computed strings
				var labl = resolve_var(item.get(LABEL));
				var sublabl = resolve_var(item.get(SUBLABEL));
				var method = item.get(METHOD);

				var option = resolve_var(item.get(OPTION));

				// if  Boolean: load ToggleMenuItem
				if (option instanceof Lang.Boolean) {
					return new WatchUi.ToggleMenuItem(labl, sublabl, method, option, {});
				}

				// if image given, load IconMenuItem				
				// if ((option instanceof WatchUi.BitmapResource)
				// 	|| (option instanceof Graphics.BufferedBitmap)
				// 	// || (option instanceof Graphics.BitmapReference)
				// 	// || (option instanceof Graphics.BufferedBitmapReference)
				// 	|| (option instanceof WatchUi.Drawable)) {

				// 	// set parameters
				// 	var params = {
				// 		:width => 30,
				// 		:height => 30,
				// 		:bitmapResource => option, 
				// 	};
				// 	var bufferedBitmap = null;
				// 	if (Graphics has :createBufferedBitmap) {
				// 		bufferedBitmap = Graphics.createBufferedBitmap(params);
				// 	} else {
				// 		bufferedBitmap = new Graphics.BufferedBitmap(params);
				// 	}
				// 	return new WatchUi.IconMenuItem(labl, sublabl, method, bufferedBitmap, {});
				// }

				// create normal MenuItem
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
				if ($.debug) {
					System.println("MenuBase::setOnLoaded " + self);
				}
				f_loaded = callback;
			}

			function setLoaded(loaded) {
				d_loaded = loaded;
			}

			function onLoaded(error) {
				if ($.debug) {
					System.println("MenuBase::onLoaded" + self);
				}
				
				d_error = error;
				d_loaded = false;		// make sure menus are reloaded, keep false
				if (f_loaded) {	f_loaded.invoke(error); }
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
			private var d_created = false;

			function initialize(menu, delegate) {
				if ($.debug) {
					System.println("MenuLoader::initialize(" + menu.title() + ")");
				}

				// store variables if needed for non-loaded menu
				var loaded = menu.loaded();
				if (!loaded) {
					// reference the menu and delegate for onLoaded
					d_menu = menu;
					d_delegate = delegate;	

					// set the callback and start loading
					menu.setOnLoaded(method(:onLoaded));
					loaded = menu.load();
				}

				// for loaded menus: check error
				var error = menu.error();
				if ((error != null) && (loaded == true)) {
					loadView(new ErrorView(error), null, WatchUi.SLIDE_IMMEDIATE);
					return;
				}

				// for empty menus, use placeholder
				if (menu.getItem(0) == null) {
					loadView(new TextView(menu.placeholder()), null, WatchUi.SLIDE_IMMEDIATE);
					return;
				}

				// load the menu
				loadView(new MenuView(menu), delegate, WatchUi.SLIDE_IMMEDIATE);
				return;
			}
			
			function loadView(view, delegate, transition) {
				if (d_created) {
					WatchUi.switchToView(view, delegate, transition);
					return;
				}
				d_created = true;
				WatchUi.pushView(view, delegate, transition);
			}

			function onLoaded(error) {
				if ($.debug) {
					System.println("MenuLoader::onLoaded( SubMusic.Error: " + (error instanceof SubMusic.Error) + ")");
				}
				// switch to error view on error
				if (error instanceof SubMusic.Error) {
					loadView(new ErrorView(error), null, WatchUi.SLIDE_IMMEDIATE);
					return;
				}

				// only show menu if there are items to show
				if (d_menu.getItem(0) == null) {
					loadView(new TextView(d_menu.placeholder()), null, WatchUi.SLIDE_IMMEDIATE);
				} else {
					loadView(new MenuView(d_menu), d_delegate, WatchUi.SLIDE_IMMEDIATE);
				}

				// allow garbage collection / reference count to zero
				d_menu = null;
				d_delegate = null;
			}
		}
	}
}
