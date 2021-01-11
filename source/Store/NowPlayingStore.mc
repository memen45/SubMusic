using Toybox.Application;
using Toybox.System;

class Playable {
    private var d_songids = [];
    private var d_refids = [];
    private var d_songidx = 0;

    function loadPlaylist(id, songid) {
        // return empty array if no id available
        if (id == null) {
            return;
        }

        var iplaylist = new IPlaylist(id);
        var ids = iplaylist.songs();
        var songidx = 0;

        // only add the songs that are available for playing
        for (var idx = 0; idx != ids.size(); ++idx) {
            var isong = new ISong(ids[idx]);

            // check for songid match
            if (isong.id() == songid) {
                d_songidx = songidx;
            }

            // not added if no refId
            if (isong.refId() == null) {
                continue;
            }

            d_songids.add(isong.id());
            d_refids.add(isong.refId());
            songidx++;
        }
    }

    function getSongIds() {
        return d_songids;
    }

    function getRefIds() {
        return d_refids;
    }

    function getSongIdx() {
        return d_songidx;
    }

    function getPlaybackPosition() {
        return 0;
    }
}

module SubMusic {
    module NowPlaying {

        var d_id = Application.Storage.getValue(Storage.PLAYLIST);
        var d_songid = null;

        // playlist id (for name, number of songs, playback position (songid))
        // songs list 
        //      song {id, refId, playback position (number in seconds)}

        function setSongId(id) {
            System.println("NowPlaying::setSongId(" + id + ")");
            d_songid = id;
        }

        function setPlaylistId(id) {
            System.println("NowPlaying::setPlaylistId(" + id + ")");

            // reset the ids
            d_id = id;
            d_songid = null;

            Application.Storage.setValue(Storage.PLAYLIST, d_id);
        }

        function playlistId() {
            return d_id;
        }

        function songId() {
            return d_songid;
        }

        function getPlayable() {
            var playable = new Playable();
            playable.loadPlaylist(d_id, d_songid);
            return playable;
        }

    }
}
