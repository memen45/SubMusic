
class Audio {

	hidden var d_audio;
	hidden var d_type;

	function initialize(id, type) {
		System.println("Audio::initialize( id = " + id + " type = " + type + " )");

		d_type = type;
		if (type.equals("podcast")) {
			d_audio = new IEpisode(id);
		} else {
			d_audio = new ISong(id);
		}
	}
	
	// getters
	function id() {
		return d_audio.id();
	}

	function time() {
		return d_audio.time();
	}

	function playback() {
		return d_audio.playback();
	}

	function setPlayback(value) {
		return d_audio.setPlayback(value);
	}
	
	function mime() {
		return d_audio.mime();
	}

	function refId() {
		return d_audio.refId();
	}
	
	function setRefId(refId) {
		return d_audio.setRefId(refId);
	}

	function type() {
		return d_type;
	}

}