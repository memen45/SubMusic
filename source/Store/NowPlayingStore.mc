using Toybox.Application;
using Toybox.System;

module SubMusic {
    module NowPlaying {

        var d_id = Application.Storage.getValue(Storage.PLAYLIST);
        var d_songid = null;

        // playlist id (for name, number of songs, playback position (songid))
        // songs list 
        //      song {id, refId, playback position (number in seconds)}

        // returns a dictionary with a refId for each id
        function getRefIds() {

            var refIds = {};
            if (d_id == null) {
                return refIds;
            }

            var iplaylist = new IPlaylist(d_id);
            var ids = iplaylist.songs();

            for (var idx = 0; idx != ids.size(); ++idx) {
                var isong = new ISong(ids[idx]);
                if (isong.refId() != null) {
                    refIds.put(isong.id(), isong.refId());
                }
            }
            return refIds;
        }

        function getSongIds() {
            return getRefIds().keys();
        }

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

    }
}
