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
		return d_storage;
	}

    function get(key) {
        return d_storage.get(key);
    }

	function set(key, value) {
		return d_storage.put(key, value);
	}
}