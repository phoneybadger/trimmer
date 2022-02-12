namespace Trimmer.Controllers {
    public class TrimController : GLib.Object {
        // all values in seconds
        public int trim_start_time;
        public int trim_end_time;
        public double duration;

        public signal void trim_failed (string error_message);
        public signal void trim_success (string success_message);

        public string video_uri;
        private string input_uri;
        private string output_uri;
        /* ffmpeg requires a file extension in the output path */
        private string file_extension;

        public void trim () {
            input_uri = sanitize (video_uri);
            select_output_uri_with_filechooser ();
            if (output_uri == null) {
                return;
            }
            string[] cmd_args = {
                "ffmpeg",
                "-loglevel",
                "error",
                "-i",   //input
                input_uri,
                "-ss",
                Granite.DateTime.seconds_to_time (trim_start_time),
                "-to",
                Granite.DateTime.seconds_to_time (trim_end_time),
                "-c", //copy without reencoding
                "copy",
                /* 
                   overwrite if already exists. This should be fine as we
                   are asking for overwrite confirmation inside the file 
                   chooser while selecting the output path
                */
                "-y",
                output_uri
            };
            if (is_ffmpeg_available ()) {
                debug ("trimming %s to output: %s", input_uri, output_uri);
                try {
                    var subprocess = new Subprocess.newv(
                        cmd_args,
                        SubprocessFlags.STDOUT_SILENCE
                    );
                    if (subprocess.wait_check ()) {
                        var success_message = "Succesfully trimmed %s, saved as %s\n"
                            .printf(input_uri, output_uri);
                        debug (success_message);
                        trim_success (success_message);
                    }
                } catch (Error e) {
                    var error_message = "Trim failed. %s\n".printf(e.message);
                    critical (error_message);
                    trim_failed (error_message);
                }
            }
        }

        private void select_output_uri_with_filechooser () {
                var file_chooser = new Gtk.FileChooserNative (
                    "Save video",
                    null,
                    Gtk.FileChooserAction.SAVE,
                    "Save",
                    "Cancel"
                );
                var video_files_filter = new Gtk.FileFilter ();
                video_files_filter.set_filter_name ("Video files");
                video_files_filter.add_mime_type ("video/*");
                file_chooser.add_filter (video_files_filter);

                file_chooser.do_overwrite_confirmation = true;

                /* 
                   Suggest an output name of input_name-trimmed.extension
                   for example
                   video.mp4 becomes video-trimmed.mp4
                */
                var filename = Utils.get_filename (video_uri);
                try {
                    file_extension = Utils.get_file_extension (video_uri);
                } catch (Utils.NoExtensionError e) {
                    /* if filename is not found choosing mp4 by default. There
                       must be a better way to do this. Perhaps by using
                       mimetype of file to guess file extension */
                    file_extension = ".mp4";
                }
                var suggested_filename = "%s-trimmed.%s".printf(filename, file_extension);
                file_chooser.set_current_name (suggested_filename);

                var response = file_chooser.run ();
                file_chooser.destroy ();

                if (response == Gtk.ResponseType.ACCEPT) {
                    var uri = file_chooser.get_uri ();
                    if (uri == null) {
                        return;
                    }
                    /* we are suggesting the user a file extension in the 
                       name field of the file chooser. But if the user goes
                       out of their way to remove it, we'll re-add the file
                       extension. Not foolproof, the user could've replaced
                       the extension with an invalid one. But in that case
                       I guess it is acceptable to just let the trim fail. */
                    try {
                        Utils.get_file_extension (uri);
                    } catch (Utils.NoExtensionError e) {
                        debug ("User inputed no extension. Adding extension");
                        uri = "%s.%s".printf(uri, file_extension);
                    }
                    output_uri = sanitize (uri);
                }
        }


        private string sanitize (string uri) {
            /*
               Removing escape characters and replacing them with spaces
               as ffmpeg doesn't work with normal escaped uris
            */
            var uri_with_spaces = Uri.unescape_string (uri);
            return uri_with_spaces;
        }

        private bool is_ffmpeg_available () {
            // TODO: change blocking subprocess call to async
            try {
                debug ("Checking ffmpeg availability");
                string[] command = {"ffmpeg", "-version"};
                var subprocess = new Subprocess.newv (command, SubprocessFlags.STDOUT_SILENCE);
                if (subprocess.wait_check ()) {
                    debug ("Found ffmpeg");
                    return true;
                }
            } catch (Error e) {
                var message = "ffmpeg not found. Trimmer requires ffmpeg.";
                critical ("Error:%s", message);
                trim_failed (message);
            }
            return false;
        }
    }
}
