class SubMusicVersion {

	private var d_major = 0;
	private var d_minor = 2;
	private var d_patch = 8;
	private var d_name = "oebalus";

	function initialize(storage) {
		if (storage == null) {
			return;
		}
		d_major = storage["major"];
		d_minor = storage["minor"];
		d_patch = storage["patch"];

        var name = storage["name"];
        if (name == null) {
            d_name = "";
            return;
        }
        d_name = name;
	}

	function compare(version) {
		if ((version == null) 
			|| (!(version instanceof SubMusicVersion))) {
			return false;
		}
		var cmp = SubMusic.Utils.compare(d_major, version.major());
		if (cmp != 0) {
			return cmp;
		}
		cmp = SubMusic.Utils.compare(d_minor, version.minor());
		if (cmp != 0) {
			return cmp;
		}
		cmp = SubMusic.Utils.compare(d_patch, version.patch());
		return cmp;
	}

	function lessthan(version) {
		return (compare(version) < 0);
	}

	function toString() {
		return d_major.toString() 
				+ "." + d_minor.toString()
				+ "." + d_patch.toString()
				+ "-" + d_name.toString();
	}

	function toStorage() {
		return {
			"version" => toString(),
			"major" => d_major,
			"minor" => d_minor,
			"patch" => d_patch,
            "name" => d_name
		};
	}

	function major() { return d_major; }
	function minor() { return d_minor; }
	function patch() { return d_patch; }
}