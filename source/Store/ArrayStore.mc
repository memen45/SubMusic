/*
 * Store number of items in an array.
 * Item class should have a function toStorage()
 */
class ArrayStore extends Store {

	function initialize(key) {
		Store.initialize(key, []);		// initialize with empty array
	}

	// returns a connected item
	function get(idx) {
//		System.println("ArrayStore::get( idx : " + idx + " )");

		var items = Store.value();
		if ((idx == null)
			|| (idx < 0)
			|| (idx >= items.size()))  {
			return null;
		}

		return items[idx];
	}

	function size() {
		return Store.value().size();
	}

	function indexOf(item) {
		return Store.value().indexOf(item.toStorage());
	}
	
	function add(item) {
		System.println("ArrayStore::add( item : " + item.toStorage() + " )");

		// return false if failed save
		if (item == null) {
			return false;
		}
		
		// save details of the item
		Store.value().add(item.toStorage());
		return Store.update();
	}

	// returns true if item id entry removed from storage or is not in storage
	function remove(item) {        
		System.println("ArrayStore::remove( item : " + item.toStorage() + " )");
		if (item == null)  {
			return true;
		}

		Store.value().remove(item.toStorage());
		return Store.update();
	}
	
	function removeAll() {
		System.println("ArrayStore::removeAll()");
		
		setValue([]);
		return Store.update();
	}
}