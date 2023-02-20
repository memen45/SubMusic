using Toybox.Application;
using Toybox.System;

class Store {

	private var d_key;			// key to set/retrieve the stored data
	private var d_value = null;	// variable that is reflected in the Application.Storage

	function initialize(key, value) {
		if ($.debug) {
			System.println("Store::initialize( key: " + key + " value: " + value + " )");
		}
		d_key = key;

		var stored = Application.Storage.getValue(d_key);
		if (stored != null) {
			d_value = stored;
			return;
		}
		d_value = value;
	}

	function value() {
		return d_value;
	}
	
	function setValue(value) {
		d_value = value;
	}

	function update() {
		var success = true;
		try {
			Application.Storage.setValue(d_key, d_value);
		} catch (exception instanceof Toybox.Lang.StorageFullException) {
			success = false;
		}
		return success;
	}
}