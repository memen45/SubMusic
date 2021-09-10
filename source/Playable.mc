module SubMusic {
    class Playable extends Storable {

        hidden var d_storage = {

            // handled by loadIds()
            "audios" => [],         // array of dictionaries with id and type
            "idcs" => [],
            "idx" => 0,             // suggested start index
            "shuffle" => false,

            "podcast_mode" => false,    // determines playback storage
        };

        function initialize(storage) {
            System.println("Playable::initialize( storage = " + storage + " )");

            Storable.initialize(storage);
        }

        function podcast_mode() {
            return get("podcast_mode");
        }

        function audios() {
            return get("audios");
        }

        function songidx() {
            return get("idx");
        }

        function idcs() {
            return get("idcs");
        }

        function size() {
            return audios().size();
        }

        function getSongId(idx) {
            return audios()[idcs()[idx]]["id"];
        }

        function shuffle() {
            return get("shuffle");
        }

        function getSongIds() {
            var ids = [];
            for (var idx = 0; idx != audios().size(); ++idx) {
                ids.add(getSongId(idx));
            }
            return ids;
        }

        function getAudio(idx) {
            idx = idcs()[idx];      // rewrite to apply shuffle
            var id = audios()[idx]["id"];
            var type = audios()[idx]["type"];
            return new Audio(id, type);
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

        function setAudio(audio) {
            for (var idx = 0; idx != audios().size(); ++idx) {
                var id = audios()[idx]["id"];
                var type = audios()[idx]["type"];
                if ((id == audio["id"])
                    && (type == audio["type"])) {
                    setIdx(idx);
                    return save();
                }
            }
            // not found
            return false;
        }

        function setSongId(songid) {
            // find id
            for (var idx = 0; idx != audios().size(); ++idx) {
                var id = audios()[idx]["id"];
                if (id == songid) {
                    setIdx(idx);
                    return save();
                }
            }
            // not found
            return false;
        }

        function setIdx(value) {
            return set("idx", value);
        }

        function setAudios(value) {
            return set("audios", value);
        }

        function setIdcs(value) {
            return set("idcs", value);
        }

        function setTypes(value) {
            return set("types", value);
        }

        function setPodcastMode(value) {
            return set("podcast_mode", value);
        }

        function setShuffle(value) {
            return set("shuffle", value);
        }

        function removeAudioByIdx(idx) {
            System.println(audios());
            System.println(idcs());

            audios().remove(audios()[idx]);   // remove the id from ids
            idcs().remove(idx);       // remove the idx from idcs

            System.println(audios().toString());
            System.println(idcs());
        }

        function removeRemoved() {

            if (audios().size() == 0) {
                return;
            }

            // check for ids that are no longer available
            var index = 0;
            var realidx = idcs()[songidx()];
            do {
                var id = audios()[index]["id"];
                var type = audios()[index]["type"];
                var audio = new Audio(id, type);

                if (audio.refId() != null) {
                    index += 1;
                    continue;
                }
                
                // this idx is removed, so no increment of idx
                audios().remove(audios()[index]);
                
                // reset or decrease songidx if needed
                if (index == realidx) {
                    setIdx(0);
                } else if (realidx > index) {
                    realidx -= 1;
                }
            } while (index != audios().size());

            // now reset idcs
            setIdcs(new[audios().size()]);
            for (var idx = 0; idx != idcs().size(); ++idx) {
                idcs()[idx] = idx;
            }
            // realidx == songidx when !shuffle
            setIdx(realidx);

            // now fix shuffle if needed
            if (shuffle()) {
                set("shuffle", false);
                shuffleIdcs(true);
            }
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
            System.println("Playable::shuffleIdcs() songids: " + audios().toString());
            System.println("Playable::shuffleIdcs() songidx: " + songidx());

            // if not shuffle, generate 0:n array for idcs
            if (!shuffle) {
                // store the current real index
                setIdx(idcs()[songidx()]);

                setIdcs(new[audios().size()]);
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

        function loadIds(ids, audioid, type) {
            System.println("IPlayable::loadIds( ids: " + ids + " audioid: " + audioid + " type: " + type);
             
            var audioidx = 0;

            // reset ids, idcs and idx
            setIdx(0);
            setIdcs([]);

            setAudios([]);

            setShuffle(false);

            // only add the audios that are available for playing
            for (var idx = 0; idx != ids.size(); ++idx) {
                var audio = new Audio(ids[idx], type);

                // check for audioid match
                if ((audio.id() == audioid)
                    || ((audioid instanceof Lang.String)
                        && (audioid.equals(audio.id())))) {
                    // set index to this audio if matched
                    setIdx(audioidx);
                    
                    // reset progress if this audio was chosen and completed
                    var time = audio.time().toNumber();
                    if (time == 0) { time = 1; }
                    var progress = 100 * audio.playback() / time;
                    var complete = (progress > 98);
                    if (complete) { audio.setPlayback(0); } 
                }

                // not added if no refId
                if (audio.refId() == null) {
                    continue;
                }

                // add to ids and indices
                idcs().add(audioidx);

                audios().add(audio.toStorage());

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
            setPodcastMode(ipodcast.podcast());
            var ids = ipodcast.episodes();

            return loadIds(ids, episodeid, Audio.PODCAST_EPISODE);
        }

        function loadPlaylist(id, songid) {
            System.println("IPlayable::loadPlaylist( id: " + id + " songid: " + songid + ")");
            
            // return empty array if no id available
            if (id == null) {
                return false;
            }

            var iplaylist = new IPlaylist(id);
            setPodcastMode(iplaylist.podcast());
            var ids = iplaylist.songs();
            
            return loadIds(ids, songid, Audio.SONG);
        }
        
        function loadSongIds(ids) {

            setPodcastMode(false);

            return loadIds(ids, null, Audio.SONG);

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