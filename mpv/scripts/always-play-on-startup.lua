-- This script will cause mpv to always play on startup (since pause=no doesn't
-- seem to work in mpv.conf)
--
-- Or that's what it used to do. Now it does nothing. It was originally meant
-- to work around watch-later data saving+restoring the pause state, but now
-- you can just do --watch-later-options-remove=pause and not have to deal with
-- this issue anymore...
--
-- ...except that will only apply to future watch-later states. To apply this
-- retroactively, at least on Linux and other Unix-like operating systems (this
-- will screw with --resume-playback-check-mtime if enabled):
--
-- cp -pR ~/.config/mpv/watch_later ~/.config/mpv/watch_later.backup
-- sed -i /^pause=/d ~/.config/mpv/watch_later/*
--
-- And then you can delete the backup directory whenever you feel confident you
-- didn't screw it up.
--
-- If this doesn't make sense for your use case and you just want the old
-- script back, then uncomment the code below:

mp.register_event("file-loaded", function()
	mp.set_property_bool("pause", false)
end)
