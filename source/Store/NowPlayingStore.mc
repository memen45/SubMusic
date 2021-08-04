using Toybox.Application;
using Toybox.System;
//using SubMusic;

module SubMusic {
    class Playable {

        // required properties
        hidden var d_songids = [];

        hidden var d_songidcs = [];
        hidden var d_songidx = 0;       // suggested start index

        hidden var d_shuffle = false;
        hidden var d_podcast = false;

        function initialize(storage) {
            System.println("Playable::initialize( storage = " + storage + " )");
            fromStorage(storage);
        }
        
        function toStorage() {
            return {
                "songids" => d_songids,

                "songidcs" => d_songidcs,
                "songidx" => d_songidx,

                "shuffle" => d_shuffle,
                "podcast" => d_podcast,
            };
        }

        function fromStorage(storage) {
            var changed = false;

            if ((storage["songids"] != null) && (d_songids != storage["songids"])) {
                d_songids = storage["songids"];
                changed = true;
            }
            if ((storage["songidcs"] != null) && (d_songidcs != storage["songidcs"])) {
                d_songidcs = storage["songidcs"];
                changed = true;
            }
            if ((storage["songidx"] != null) && (d_songidx != storage["songidx"])) {
                d_songidx = storage["songidx"];
                changed = true;
            }
            
            if ((storage["shuffle"] != null) && (d_shuffle != storage["shuffle"])) {
                d_shuffle = storage["shuffle"];
                changed = true;
            }
            if ((storage["podcast"] != null) && (d_podcast != storage["podcast"])) {
                d_podcast = storage["podcast"];
                changed = true;
            }

            // check for ids that are no longer available
            var removed = [];
            for (var idx = 0; idx != d_songids.size(); ++idx) {
                var id = d_songids[idx];
                var isong = new ISong(id);

                // if no refid, add to removed songs
                if (isong.refId() == null){ 
                    removed.add(idx);
                }
            }

            // remove the unavailable from the current playlist
            for (var idx = 0; idx != removed.size(); ++idx) {
                var songidx = removed[idx];

                // remove from id list
                d_songids.remove(d_songids[songidx]);

                // remove from idcs
                d_songidcs.remove(songidx);
            }

            // reset songidx if exceeding the new size
            if (d_songidx >= d_songidcs.size()) {
                d_songidx = 0;
            }
            return changed;
        }

        function size() {
            return d_songids.size();
        }

        function getSongId(idx) {
            return d_songids[d_songidcs[idx]];
        }

        function shuffle() {
            return d_shuffle;
        }

        function getSongIds() {
            return d_songids;
        }

        function songIdx() {
            return d_songidx;
        }

        function podcast() {
            return d_podcast;
        }
    }

    class IPlayable extends Playable {

        function initialize() {
            System.println("IPlayable::initialize()");

            var storage = PlayableStore.get();
            if (storage == null) {
                storage = {};
            }

            Playable.initialize(storage);
        }

        function save() {
            return PlayableStore.save(self);
        }


        function incSongIdx() {
            d_songidx++;
            return save();
        }

        function decSongIdx() {
            d_songidx--;
            return save();
        }

        function setSongId(songid) {
            var idx = d_songids.indexOf(songid);
            if (idx < 0) {
                return false;
            }
            idx = d_songidcs.indexOf(idx);
            if (idx < 0) {
                return false;
            }
            d_songidx = idx;

            return save();
        }

        function shuffleIdcs(shuffle) {
            // nothing to do if same or no songs on list
            if (d_shuffle == shuffle) {
                return false;
            }

            d_shuffle = shuffle;
            
            // empty list cannot be shuffled
            if (size() == 0) {
                return false;
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
                return save();
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

            return save();
        }

        function loadPlaylist(id, songid) {
            System.println("IPlayable::loadPlaylist( id: " + id + " songid: " + songid + ")");
            
            // return empty array if no id available
            if (id == null) {
                return false;
            }

            var iplaylist = new IPlaylist(id);
            d_podcast = iplaylist.podcast();
            var ids = iplaylist.songs();
            var songidx = 0;

            d_songids = [];
            d_songidcs = [];
            d_songidx = 0;

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
                d_songidcs.add(songidx);

                songidx++;
            }

            return save();
        }
        
        function loadSongIds(ids) {
            IPlayable.initialize();

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

            return save();
        }
    }

    module PlayableStore {

        var d_store = new Store(Storage.PLAYABLE, {});

        function get() {
            return d_store.value();
        }

        // these functions should be used only internally by IPlayable class
        function save(playable) {
            d_store.setValue(playable.toStorage());
            return d_store.update(); 
        }

        function remove() {
            d_store.setValue(null);
            return d_store.update();
        }
    }
}
