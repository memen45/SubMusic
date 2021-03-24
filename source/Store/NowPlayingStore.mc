using Toybox.Application;
using Toybox.System;

class Playable {

    hidden var d_songids = [];
    // hidden var d_refids = [];

    hidden var d_songidcs = [];
    hidden var d_songidx = 0;       // suggested start index

    hidden var d_shuffle = false;
    hidden var d_podcast = false;

    function initialize() {
    }

    function fromStorage(storage) {
    	if (storage == null) {
    		return;
    	}
    	
        d_songids = storage["songids"];
        // d_refids = storage["refids"];

        d_songidcs = storage["songidcs"];
        d_songidx = storage["songidx"];

        d_shuffle = storage["shuffle"];
        d_podcast = storage["podcast"];
    }

    function toStorage() {
        return {
            "songids" => d_songids,
            // "refids" => d_refids,

            "songidcs" => d_songidcs,
            "songidx" => d_songidx,

            "shuffle" => d_shuffle,
            "podcast" => d_podcast,
        };
    }

    function size() {
        return d_songids.size();
    }

    function getSongId(idx) {
        return d_songids[d_songidcs[idx]];
    }

    // function getRefId(idx) {
    //     return d_refids[d_songidcs[idx]];
    // }

    function shuffle() {
        return d_shuffle;
    }

    function shuffleIdcs(shuffle) {
        // nothing to do if same or no songs on list
        if (d_shuffle == shuffle) {
            return;
        }

        d_shuffle = shuffle;
        
       	// empty list cannot be shuffled
        if (size() == 0) {
        	return;
        }

        System.println("Playable::shuffleIdcs() Before: " + d_songidcs);
        System.println("Playable::shuffleIdcs() songids: " + d_songids);
        System.println("Playable::shuffleIdcs() songidx: " + d_songidx);

        // if not shuffle, generate 0:n array for idcs
        if (!shuffle) {
            // store the current real index
            d_songidx = d_songidcs[d_songidx];

            d_songidcs = new[d_songids.size()];
            for (var idx = 0; idx != d_songidcs.size(); ++idx) {
                d_songidcs[idx] = idx;
            }
            System.println("Playable::shuffleIdcs() After unshuffle:" + d_songidcs);
            return;
        }

        // shuffle idcs around current
        var current = d_songidcs[d_songidx];

        // shuffle the idcs
        var tmp = d_songidcs[0];
        d_songidcs[0] = d_songidcs[d_songidx];
        d_songidcs[d_songidx] = tmp;

        for (var idx = 1; idx != d_songidcs.size(); ++idx) {
            tmp = d_songidcs[idx];
			var other = (Math.rand() % (d_songidcs.size() - idx)) + idx;
			d_songidcs[idx] = d_songidcs[other];
			d_songidcs[other] = tmp;
        }
        
        System.println("Playable::shuffleIdcs() After shuffle:" + d_songidcs);

        // slice last songs and prepend to account for songidx
        var splitidx = d_songidx;
        var end = d_songidcs.slice(0, -splitidx);
        d_songidcs = d_songidcs.slice(-splitidx, null);
        d_songidcs.addAll(end);
        
        System.println("Playable::shuffleIdcs() After shuffle:" + d_songidcs);
    } 

    function getSongIds() {
        return d_songids;
    }

    // function getRefIds() {
    //     return d_refids;
    // }

    function songIdx() {
        return d_songidx;
    }

    function incSongIdx() {
        d_songidx++;
    }

    function decSongIdx() {
        d_songidx--;
    }

    function setSongId(songid) {
        var idx = d_songids.indexOf(songid);
        if (idx < 0) {
            return;
        }
        idx = d_songidcs.indexOf(idx);
        if (idx < 0) {
            return;
        }
        d_songidx = idx;
    }

    function podcast() {
        return d_podcast;
    }
}

class PlaylistPlayable extends Playable {

    function initialize(id, songid) {
        Playable.initialize();

        loadPlaylist(id, songid);
    }

    function loadPlaylist(id, songid) {
    	System.println("PlaylistPlayable::loadPlaylist( id: " + id + " songid: " + songid + ")");
    	
        // return empty array if no id available
        if (id == null) {
            return;
        }

        var iplaylist = new IPlaylist(id);
        d_podcast = iplaylist.podcast();
        var ids = iplaylist.songs();
        var songidx = 0;

        // only add the songs that are available for playing
        for (var idx = 0; idx != ids.size(); ++idx) {
            var isong = new ISong(ids[idx]);

            // check for songid match
            if ((isong.id() == songid)
            	|| ((songid instanceof Lang.String)
            		&& (songid.equals(isong.id())))) {
                d_songidx = songidx;
                
                // reset progress if this song was chosen
                var progress = 100 * isong.playback() / isong.time();
                var complete = (progress > 98);
                if (complete) { isong.setPlayback(0); } 
            }

            // not added if no refId
            if (isong.refId() == null) {
                continue;
            }

            // store id, refid and index
            d_songids.add(isong.id());
            // d_refids.add(isong.refId());
            d_songidcs.add(songidx);

            songidx++;
        }
    }
}

// creates a playable object based on some song ids
class SongsPlayable extends Playable {
    function initialize(ids) {
        Playable.initialize();

		var songidx = 0;
        for (var idx = 0; idx != ids.size(); ++idx) {
        	var isong = new ISong(ids[idx]);
        	
        	// not added if no refId
            if (isong.refId() == null) {
                continue;
            }
            
            d_songids.add(isong.id());
            d_songidcs.add(songidx);
        }
    }
}

module SubMusic {
    module NowPlaying {

        var d_playable = null;

        // playlist id (for name, number of songs, playback position (songid))
        // songs list 
        //      song {id, refId, playback position (number in seconds)}
        
        function initialize() {
        	d_playable = new Playable();
        	var storage = Application.Storage.getValue(Storage.PLAYABLE);
        	d_playable.fromStorage(storage);
        }

        function setPlayable(playable) {
            d_playable = playable;
            Application.Storage.setValue(Storage.PLAYABLE, playable.toStorage());
        }

        function getPlayable() {
            if (d_playable == null) {
                initialize();
            }
            return d_playable;
        }
    }
}
