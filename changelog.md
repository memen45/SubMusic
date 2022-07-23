Version [] - 

Version [0.2.1] - 23-07-2022
- added setting to disable 30s skip forward/backward buttons (issue #13, #43)
- added app settings view to watch menu (Menu > About > Settings)

Version [0.2.0] - 2022-06-26
- Launch icon resolution improved
- fix HTTP Basic authentication (subsonic only)

Version [0.1.25] - 2022-06-24
- added HTTP Basic authentication (subsonic only)
- added support for d2mach1, fr255m, fr255sm, fr955

Version [0.1.24] - 2022-02-16
- added support for d2airx10, epix2, fenix7, fenix7s , fenix7x, venu2plus
- fixed null response handling in server info

Version [0.1.23] - 2021-11-11
- workaround for BAD RESPONSE when no playlists/podcasts/songs (airsonic, airsonic-advanced)

Version [0.1.22] - 2021-11-07
- fix race condition (error now shows immediately instead of after Back)
- fix Subsonic Unknown Api error: now reports BADRESPONSE
- fixed interrupted sync due to max time (serialisation speed improved)
- fixed issue with error handling
- fixed "No remote playlists", when actually still loading

Version [0.1.21] - 2021-10-26
- fix crash on open due to reloading playlist from storage

Version [0.1.20] - 2021-10-23
- fix crash on AmpacheError
- fix crash on choose song in Now Playing menu

Version [0.1.19] - 2021-10-15
- updated Ampache5 Error codes (backwards compatible)
- improved speed in Song access during play
- fixed removal of removed songs (now performed after complete sync)
- fixed issue on trying to sync artwork with id null

Version [0.1.18] - 2021-09-18
- fixed pre loading of all nested menus (now only when opened)
- improved sync speed long playlists
- fixed ArtWork sync crash

Version [0.1.17] - 2021-09-15
- fixed cancelled sync when Podcast feature not available on server
- added podcasts to Test Server option

Version [0.1.16] - 2021-09-15
- fixed several minor bugs

Version [0.1.15] - 2021-09-10
- fixed episode loading on Subsonic (still fails when too many episodes)
- fixed progress bar during audio sync (32-bit overflow on large files)

Version [0.1.14] - 2021-09-09
- added software version number in settings
- rewrite of sync engine
- rewrite of menu structure
- added experimental podcast support (newest file only)
- added artwork support for podcasts
- fixed "remove all" option in menu in case cache was already removed
- fixed missing songs filter (related to crashes and resets)

Version [0.1.13] - 2021-08-30
- fixed Media Error when song removed from playlist (before end)
- fixed reset initial shuffle state on 'Play' playlist

Version [0.1.12] - 2021-08-25
- fixed Media Error when song removed from playlist fix

Version [0.1.11] - 2021-08-04
- fixed Media Error when song removed from playlist
- fixed Now Playing persistence between sessions

Version [0.1.10] - 2021-06-23
- fixed response checking (rare crash on some metadata)
- improved error reporting
- added support for forerunner 945 LTE

Version [0.1.9] - 2021-06-02
- fixed support for venu2s (Garmin bug with loading resource strings)

Version [0.1.8] - 2021-05-22
- added artwork for both Subsonic and Ampache backends
- added support for descentmk2s, venu2 and venu2s

Version [0.1.7] - 2021-03-24
- fixed error catching (subsonic get playlist)
- fixed shuffle on empty playlist

Version [0.1.6] - 2021-02-23
- fixed Error on malformed response (subsonic)
- fixed filtering nonlocal songs in Play All feature
- fixed potential out of memory error when scrobble sync fails

Version [0.1.5] - 2021-01-20
- fixed crash on unshuffle
- fixed update storage (if old version is less than current)
- added Play All menu option to play all stored songs at once without playlist

Version [0.1.4] - 2021-01-19
- fixed charge blocked on auto sync hang (Garmin bug workaround)
- added playables to store state in between sessions
- added shuffle to stored state
- added shuffle option to playlist options
- added podcast mode to play with persistent playback position

Version [0.1.3] - 2021-01-11
- fixes playlist order - now reflecting server changes
- fixes bluetooth headphone 'skip' behaviour (feedback required)
- fixes empty screen when no local playlists are available

Version [0.1.2] - 2021-01-03
- fixes 'choose playlist'
- added start play by song (Playlists -> playlist1 -> Songs)

Version [0.1.1] - 2020-12-30
- fixed broken error report views
- bug fixes and improvements

Version [0.1.0] - 2020-12-28
- added Now Playing option to play per song
- fixes Subsonic scrobble 
- added granular progress during sync 

Version [0.0.24] - 2020-12-18
- fixed sync issues (delete after sync)
- added interrupting syncs on errors that cannot be skipped/handled

Version [0.0.23] - 2020-12-15
- added support for updating play count to server (feedback required)
- added warning for possibly hanging sync
- update last sync in menu
- refactor in menus
- fixes potential ampache crash 

Version [0.0.22] - 2020-12-09
- added 'More...' to playback configuration to open sync menu
- fixed hanging sync (feedback required)
- fixed error on error string creation

Version [0.0.21] - 2020-12-08
- added ping to check server version
- fixed duplicate check AmpacheError
- fixed crash on display HttpError
- fixed potential cause of onStream exception (Subsonic)
- added donate link to menu: https://www.paypal.com/donate?hosted_button_id=HBUU64LT3QWA4

Version [0.0.20] - 2020-12-02
- fixed progressbar - only count songs that are not yet local
- fixed crash on sync empty playlist (progress divide by 0)
- fixed initial Sync setup (removed deprecated methods)
- fixed crashes on Error handling
- fixed hot reloading of settings
- refactor of menus
- added last sync time record
- added support for descentmk2 devices

Version [0.0.19] - 2020-11-20
- refactor of sync engine
- fixed stack overflow error (rare case)
- fixed progress bar during sync
- improved error handling and reporting 

Version [0.0.18] - 2020-11-03
- fixed updating settings with Subsonic API
- fixed possible crash on received null values

Version [0.0.17] - 2020-10-18
- added dynamic limit for response size (Ampache API)
- added handling 'session expired' error (Ampache API)
- fixed progressbar during sync (remote playlists do not count)
- fixed order of playlists, locals always first
- fixed some crashes
- added support for D2 Air, Sq. Music

Version [0.0.16] - 2020-10-08
- added support for d2 delta series and Venu Mercedes-Benz Collection
- fixed null handling (Nextcloud + SMB storage bug)
- fixed incorrect progressbar
- upgrade to storage, requires resync (no reinstall needed)
- improved speed of playback selection
- fixes syncing playlist metadata in background
- fixed managing playlists that are no longer online ('local only')
- fixed marking of incompletely synced playlist ('needs sync')
- added support for adts, wav, mp4 file types (defaults to mp3)

Version [0.0.15] - 2020-08-17
- fixes crash on changing settings
- fixes crash on initialize playlist before sync
- fixes crash on sync with null local songs

Version [0.0.14] - 2020-07-16
- fixes reset session on settings changed (AmpacheAPI)
- fixes potential bug from outdated storage
- fixes error reporting in "Server Info" tab
- fixes sync - 'fake sync' bug
- fixes crash on receiving error (AmpacheAPI)

Version 0.0.13
- added "Server Info" option to the menu to test connection

Version 0.0.12
- minor bug fixes
- improved support for the Ampache API (awaiting nextcloud/music update)

Version 0.0.11
- fixes playback configuration

Version 0.0.10
- rewrite of the sync engine
- alpha support for the Ampache API (limited to 20 songs per playlist)

Version 0.0.9
- added support for removing playlists before sync occured
- added handling of unsupported file types (songs will be skipped)
- improved syncing

Version 0.0.8
- fixes content-type issue on airsonic servers
- minor ui changes

Version 0.0.7
- fixes error reporting
- fixes response verifications

Version 0.0.6
- fixes multiple deletion of same playlist error

Version 0.0.5
- fixes broken sync

Version 0.0.4
- fixes strict responses from Airsonic (possibly also from other Subsonic servers)
- fixes response "ok" verification (less "Media Error Occured" and improves error reporting)
- fixed supported Subsonic API version: 1.10.2

Version 0.0.3
- fixes "Media Error Occured" on initial sync

Version 0.0.2
- fixes duplicate deletion of cached songs
- fixes deletion of playlists

Version 0.0.1
- show available playlists in Configure Sync menu
- only delete songs when not present in any playlist
- incremental change supported (only download new songs)