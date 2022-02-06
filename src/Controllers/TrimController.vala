namespace Trimmer.Controllers {
    public class TrimController : GLib.Object {
        // all values in seconds
        public int trim_start_time;
        public int trim_end_time;
        private double _duration;

        public double duration {
            get {
                return _duration;
            } set {
                _duration = value;
            }
        }

        public string video_uri;

        public void trim () {
            var input_uri = sanitize (video_uri);
            var output_uri = sanitize (generate_output_uri (input_uri));
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
                /* overwrite if already exists. Assuming this won't be problematic
                   as we are generating a custom output uri which has very low
                   chance of overlap */
                "-y",
                output_uri
            };
            if (is_ffmpeg_available ()) {
                print(generate_output_uri (input_uri));
                try {
                    var subprocess = new Subprocess.newv(
                        cmd_args,
                        SubprocessFlags.STDOUT_SILENCE
                    );
                    if (subprocess.wait_check ()) {
                        debug ("Succesfully trimmed %s, saved as %s\n", input_uri, output_uri);
                    }
                } catch (Error e) {
                    critical ("Trim failed %s\n", e.message);
                }
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

        private string generate_output_uri (string input_uri) {
            try {
                /*
                    turns file.extension into file-trimmed-start-end.extension
                    for example
                    input.mp4 becomes
                    input-trimmed-2:00-3:00.mp4
                */
                var file_regex = new GLib.Regex ("""(\/[^/]+)(\.\w+)$""");
                var timestamp_suffix = (
                    "trimmed-" +
                    Granite.DateTime.seconds_to_time (trim_start_time) +
                    "-" +
                    Granite.DateTime.seconds_to_time (trim_end_time)
                );
                string output_name = file_regex.replace (
                    input_uri,
                    input_uri.length,
                    0,
                    """\1-""" +
                    timestamp_suffix
                    + """\2""");
                return output_name;
            } catch (RegexError e) {
                stderr.printf ("Error on file: %s", e.message);
                return "";
            }
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
                var message = "Trimmer requires ffmpeg";
                critical ("Error:%s", message);
            }
            return false;
        }
    }
}
