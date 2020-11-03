class SubMusicVersion {

	private var d_major = 0;
	private var d_minor = 0;
	private var d_patch = 18;
	private var d_name = "sigma";

	function initialize(storage) {
		if (storage == null) {
			return;
		}
		d_major = storage["major"];
		d_minor = storage["minor"];
		d_patch = storage["patch"];

        name = storage["name"];
        if (name == null) {
            d_name = "";
            return;
        }
        d_name = name;
	}

	function equals(storage) {
		if (storage == null) {
			return false;
		}
		if (!(storage instanceof Lang.Dictionary)) {
			return false;
		}
		return toString().equals(storage["version"]);
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
}