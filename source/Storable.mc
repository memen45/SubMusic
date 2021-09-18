class Storable {

	function initialize(storage) {
		// System.println("Storable::initialize( storage : " + storage + " )");

		fromStorage(storage);
	}

	function fromStorage(storage) {
		var changed = false;

		// iterate over all keys 
		var keys = d_storage.keys();
		for (var idx = 0; idx != keys.size(); ++idx) {
			var key = keys[idx];

			// update value if not null and not equal
			if ((storage[key] != null) && (d_storage[key] != storage[key])) {
				d_storage[key] = storage[key];
				changed = true;
			}
		}
		return changed;
	}
	
	function toStorage() {
		return el_to_storage(d_storage);
	}

	// decision for storage 
	function el_to_storage(el) {
		if (el instanceof Storable) {
			return el.toStorage();
		}
		if (el instanceof Lang.Array) {
			return array_to_storage(el);
		}
		if (el instanceof Lang.Dictionary) {
			return dict_to_storage(el);
		}
		return el;
	}

	// iterate over all elements in the array to convert to storage
	function array_to_storage(array) {
		System.println("Storable::array_to_storage( array: " + array + " )");

		var ret = new [array.size()];
		for (var idx = 0; idx != array.size(); ++idx) {
			ret[idx] = el_to_storage(array[idx]);
		}
		return ret;
	}

	// iterate over all elements in the dictionary to convert to storage
	function dict_to_storage(dict) {
		var ret = {};

		var keys = dict.keys();
		for (var idx = 0; idx != keys.size(); ++idx) {
			var key = keys[idx];
			ret[key] = el_to_storage(dict[key]);
		}
		return ret;
	}

	// update key, returns true if changed
	// checks for equality and string equality
	function updateAny(key, value) {
		var current = get(key);
		if (value == current) {
			return false;
		}
		if ((value instanceof Lang.String) 
			&& (current instanceof Lang.String)
			&& (value.equals(current))) {
			return false;
		}

		// update value, as it is not equal
		set(key, value);

		// mark changed
		return true;
	}

    function get(key) {
        return d_storage.get(key);
    }

	function set(key, value) {
		return d_storage.put(key, value);
	}
}