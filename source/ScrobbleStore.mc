class Scrobble {
	
	private var d_id;
	private var d_time;
	
	function initialize(storage) {
		d_id = storage["id"];
		
		d_time = storage["time"];
		if (d_time == null) {
			d_time = Time.now().value().format("%i");
		}
	}
	
	function id() {
		return d_id;
	}
	
	function time() {
		return d_time;
	}
	
	function toStorage() {
		return {
			"id" => d_id,
			"time" => d_time,
		};
	}
}

module ScrobbleStore {
 
 	var d_store = new ArrayStore(Storage.PLAY_RECORDS);
	
	function add(item) {
		d_store.add(item);
	}
	
	function get(idx) {
		return d_store.get(idx);
	}
	
	function size() {
		return d_store.size();
	}
	
	function remove(item) {
		return d_store.remove(item);
	}
	
	function removeAll() {
		return d_store.removeAll();
	}
}