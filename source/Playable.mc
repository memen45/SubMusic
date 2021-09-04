using SubMusic.Utils;

module SubMusic {
    class Playable extends Storable {

        hidden var d_storage = {

            // handled by loadIds()
            "ids" => [],
            "idcs" => [],
            "idx" => 0,             // suggested start index
            "shuffle" => false,

            "podcast_mode" => false,    // determines playback storage
            "episodes" => false,         // denotes whether we have episodes or songs
        };           

        function initialize(storage) {
            System.println("Playable::initialize( storage = " + storage + " )");

            Storable.initialize(storage);
        }

        function episodes() {
            return get("episodes");
        }

        function podcast_mode() {
            return get("podcast_mode");
        }

        function ids() {
            return get("ids");
        }

        function songidx() {
            return get("idx");
        }

        function idcs() {
            return get("idcs");
        }

        function size() {
            return ids().size();
        }

        function getSongId(idx) {
            return ids()[idcs()[idx]];
        }

        function shuffle() {
            return get("shuffle");
        }

        function getSongIds() {
            return ids();
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
            
            // remove if not available
            removeRemoved();
        }

        function save() {
            return PlayableStore.save(self);
        }


        function incSongIdx() {
            setIdx(songidx() + 1);
            return save();
        }

        function decSongIdx() {
            setIdx(songidx() - 1);
            return save();
        }

        function setSongId(songid) {
            var idx = ids().indexOf(songid);
            if (idx < 0) {
                return false;
            }
            idx = idcs().indexOf(idx);
            if (idx < 0) {
                return false;
            }
            setIdx(idx);

            return save();
        }

        function setIdx(value) {
            return set("idx", value);
        }

        function setIds(value) {
            return set("ids", value);
        }

        function setIdcs(value) {
            return set("idcs", value);
        }

        function setEpisodes(value) {
            return set("episodes", value);
        }

        function setPodcastMode(value) {
            return set("podcast_mode", value);
        }

        function setShuffle(value) {
            return set("shuffle", value);
        }

        function type() {
            if (episodes()) {
                return "podcast";
            }
            return "song";
        }

        function removeRemoved() {
            // check for ids that are no longer available
            var removed = [];
            var ids = ids();
            System.println(ids);
            for (var idx = 0; idx != ids.size(); ++idx) {
                var id = ids[idx];
                var audio = new Audio(id, type());

                // if no refid, add id and idx to removed ids
                if (audio.refId() == null){ 
                    // add id to removed array
                    removed.add(id);
                    
                    // remove this idx from idcs 
                    idcs().remove(idx);
                }
            }

            // remove ids from current ids
            for (var idx = 0; idx != removed.size(); ++idx) {
                ids.remove(removed[idx]);
            }
            
            System.println(idcs().toString());
            
            // fix idcs, first get sorting, then fill in 0...N given the sort order
            var sorted_idcs = SubMusic.Utils.sort_idcs(idcs());
            for (var idx = 0; idx != sorted_idcs.size(); ++idx) {
                idcs()[sorted_idcs[idx]] = idx;
            }
            
            System.println(idcs().toString());

            // reset idx if exceeding the new size
            if (songidx() >= idcs().size()) {
                setIdx(0);
            }
            setIds(ids);
        }

        function shuffleIdcs(shuffle) {
            // nothing to do if same or no songs on list
            if (shuffle() == shuffle) {
                return false;
            }

            setShuffle(shuffle);
            
            // empty list cannot be shuffled
            if (size() == 0) {
                return false;
            }

            System.println("Playable::shuffleIdcs() Before: " + idcs());
            System.println("Playable::shuffleIdcs() songids: " + ids());
            System.println("Playable::shuffleIdcs() songidx: " + songidx());

            // if not shuffle, generate 0:n array for idcs
            if (!shuffle) {
                // store the current real index
                setIdx(idcs()[songidx()]);

                setIdcs(new[ids().size()]);
                for (var idx = 0; idx != idcs().size(); ++idx) {
                    idcs()[idx] = idx;
                }
                System.println("Playable::shuffleIdcs() After unshuffle:" + idcs());
                return save();
            }

            // shuffle idcs around current
            var current = idcs()[songidx()];

            // shuffle the idcs
            var tmp = idcs()[0];
            idcs()[0] = idcs()[songidx()];
            idcs()[songidx()] = tmp;

            for (var idx = 1; idx != idcs().size(); ++idx) {
                tmp = idcs()[idx];
                var other = (Math.rand() % (idcs().size() - idx)) + idx;
                idcs()[idx] = idcs()[other];
                idcs()[other] = tmp;
            }
            
            System.println("Playable::shuffleIdcs() After shuffle:" + idcs());

            // slice last songs and prepend to account for songidx
            var splitidx = songidx();
            var end = idcs().slice(0, -splitidx);
            setIdcs(idcs().slice(-splitidx, null));
            idcs().addAll(end);
            
            System.println("Playable::shuffleIdcs() After shuffle:" + idcs());

            return save();
        }

        function loadIds(ids, audioid) {
            var audioidx = 0;

            // reset ids, idcs and idx
            setIdx(0);
            setIds([]);
            setIdcs([]);

            setShuffle(false);

            // only add the audios that are available for playing
            for (var idx = 0; idx != ids.size(); ++idx) {
                var audio = new Audio(ids[idx], type());

                // check for audioid match
                if ((audio.id() == audioid)
                    || ((audioid instanceof Lang.String)
                        && (audioid.equals(audio.id())))) {
                    // set index to this audio if matched
                    setIdx(audioidx);
                    
                    // reset progress if this audio was chosen and completed
                    var progress = 100 * audio.playback() / audio.time();
                    var complete = (progress > 98);
                    if (complete) { audio.setPlayback(0); } 
                }

                // not added if no refId
                if (audio.refId() == null) {
                    continue;
                }

                // add to ids and indices
                ids().add(audio.id());
                idcs().add(audioidx);

                audioidx++;
            }

            return save();
        }

        function loadPodcast(id, episodeid) {
            System.println("IPlayable::loadPodcast( id: " + id + " episodeid: " + episodeid + ")");
            
            // return empty array if no id available
            if (id == null) {
                return false;
            }

            var ipodcast = new IPodcast(id);
            setEpisodes(true);                       // these are episodes
            setPodcastMode(ipodcast.podcast());
            var ids = ipodcast.episodes();

            return loadIds(ids, episodeid);
        }

        function loadPlaylist(id, songid) {
            System.println("IPlayable::loadPlaylist( id: " + id + " songid: " + songid + ")");
            
            // return empty array if no id available
            if (id == null) {
                return false;
            }

            var iplaylist = new IPlaylist(id);
            setEpisodes(false);                       // these are songs, not episodes
            setPodcastMode(iplaylist.podcast());
            var ids = iplaylist.songs();
            
            return loadIds(ids, songid);
        }
        
        function loadSongIds(ids) {

            setEpisodes(false);                       // these are songs, not episodes
            setPodcastMode(false);

            return loadIds(ids, null);

            // var songidx = 0;
            // for (var idx = 0; idx != ids.size(); ++idx) {
            //     var isong = new ISong(ids[idx]);
                
            //     // not added if no refId
            //     if (isong.refId() == null) {
            //         continue;
            //     }
                
            //     ids().add(isong.id());
            //     idcs().add(songidx);
            // }

            // return save();
        }
    }
}