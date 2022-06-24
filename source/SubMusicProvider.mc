using Toybox.Application;

module SubMusic {
	module Provider {
		var d_provider = null;
		var d_type;
		
		function get() {
			if (d_provider != null) {
				return d_provider;
			}
			
			// construct the selected provider
	        var settings = getProviderSettings();
	        d_type = settings["api_typ"];
	        return createProvider(settings);
	    }
	    
	    function getProviderSettings() {
	    	return {
	    		"api_typ" => Application.Properties.getValue("API_standard"),
	        	"api_url" => Application.Properties.getValue("subsonic_API_URL"),
				"api_usr" => Application.Properties.getValue("subsonic_API_usr"),
				"api_key" => Application.Properties.getValue("subsonic_API_key"),
				"api_aut" => Application.Properties.getValue("subsonic_AUTH_method"),
			};
	    }
	    
	    function createProvider(settings) {
	    	if (d_type == ApiStandard.AMPACHE) {
	        	d_provider = new AmpacheProvider(settings);
	        } else {
	        	d_provider = new SubsonicProvider(settings);
	        }
	        return d_provider;
	    }
	    
	    function onSettingsChanged() {
	    	if (d_provider == null) {
	    		return null;
	    	}
	    	
	    	var settings = getProviderSettings();
	    	var type = settings["api_typ"];
	    	
	    	if (type == d_type) {
	    		d_provider.onSettingsChanged(settings);
	    		return null;
	    	}
	    	
	    	d_type = type;
	    	
	    	return createProvider(settings);	    	
	    }
	}
}