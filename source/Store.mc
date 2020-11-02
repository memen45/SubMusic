using Toybox.Application;

/*
 * Store number of items by id. 
 * Item class should have a function id()
 * Item class should have a function toStorage()
 */

class Store {
	
	// dictionary by item id (all saved items)
	private var d_items = {};
	private var d_initialized = false;
    private var d_key;

	function initialize(key) {
		System.println("Store::initialize()");

        d_key = key;

		var items = Application.Storage.getValue(d_key);
		if (items != null) {
			d_items = items;
		}
		d_initialized = true;
	}

	// returns a connected item
	function get(id) {
		System.println("Store::get( id : " + id + " )");
		if (id == null)  {
			return null;
		}

		if (!d_initialized) {
			initialize();
		}
		return d_items.get(id);
	}

	function getIds() {
		System.println("Store::getIds()");
		if (!d_initialized) {
			initialize();
		}
		
		return d_items.keys();
	}
	
	function save(item) {
		System.println("Store::save( item : " + item.toStorage() + " )");
		
		// initialize if needed
		if (!d_initialized) {
			initialize();
		}

		// return false if failed save
		var id = item.id();
		if (id == null) {
			return false;
		}
		
		// save details of the item
		d_items.put(id, item.toStorage());
		Application.Storage.setValue(d_key, d_items);

		// indicate successful save
		return true;
	}

	// returns true if item id entry removed from storage or is not in storage
	function remove(item) {
        var id = item.id();
        
		System.println("Store::remove( id : " + id + " )");
		if (id == null)  {
			return true;
		}

		if (!d_initialized) {
			initialize();
		}

		d_items.remove(id);
		Application.Storage.setValue(Storage.PLAYLISTS, d_items);
		return true;
	}
}