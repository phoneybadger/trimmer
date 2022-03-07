/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
namespace Trimmer.Controllers {
    public class TrimController : GLib.Object {
        // all values in seconds
        private int _trim_end_time;
        public int trim_start_time {get; set;}
        public int trim_end_time {
            get {
                return _trim_end_time;
            } set {
                if (value > duration) {
                    _trim_end_time = (int) duration;
                } else {
                    _trim_end_time = value;
                }
            }
        }
        public double duration {get; set;}

        private const double DEFAULT_START = 1.0 / 4.0;
        private const double DEFAULT_END = 3.0 / 4.0;

        public signal void trim_failed (string error_message);
        public signal void trim_success (string success_message);

        public string video_uri {get; set;}
        public string save_file_uri;
        public string filename;
        /* ffmpeg requires a file extension to perform the trim */
        public string file_extension;

        public TrimState trim_state {get; set;}
        public enum TrimState {
            IDLE,
            TRIMMING
        }

        construct {
            trim_state = TrimState.IDLE;
            notify ["duration"].connect (() => {
                trim_start_time = (int) (DEFAULT_START * duration);
                trim_end_time = (int) (DEFAULT_END * duration);
            });

            notify ["video-uri"].connect (() => {
                filename = Utils.get_filename (video_uri);
                try {
                    file_extension = Utils.get_file_extension (video_uri);
                } catch (Utils.NoExtensionError e) {
                    /* defaulting to mp4 if no extension is found. There could
                    be a better way to do this using MIME types or something */
                    file_extension = "mp4";
                }
            });
        }

        public async void trim () {
            is_ffmpeg_available.begin ((obj, res) => {
                var is_available = is_ffmpeg_available.end (res);
                if (is_available) {
                    trim_with_ffmpeg.begin ();
                }
            });
        }

        private async bool is_ffmpeg_available () {
            try {
                debug ("Checking ffmpeg availability");
                string[] command = {"ffmpeg", "-version"};
                var subprocess = new Subprocess.newv (command, SubprocessFlags.STDOUT_SILENCE);
                if (yield subprocess.wait_check_async ()) {
                    debug ("Found ffmpeg");
                    return true;
                }
            } catch (Error e) {
                var message = _("ffmpeg not found. Trimmer requires ffmpeg.");
                critical ("Error:%s", message);
                trim_failed (message);
            }
            return false;
        }

        private async void trim_with_ffmpeg () {
            trim_state = TrimState.TRIMMING;
            var input_uri = sanitize (video_uri);
            var output_uri = sanitize (save_file_uri);
            debug ("trimming %s to output: %s", input_uri, output_uri);
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

            try {
                var subprocess = new Subprocess.newv (
                    cmd_args,
                    SubprocessFlags.STDOUT_SILENCE
                );
                if (yield subprocess.wait_check_async ()) {
                    /// TRANSLATORS: first %s represents the original file
                    /// name and the second one is the output file name
                    var success_message = _("Succesfully trimmed %s, saved as %s\n")
                        .printf (input_uri, output_uri);
                    debug (success_message);
                    trim_success (success_message);
                }
            } catch (Error e) {
                /// TRANSLATORS: %s in an error message
                var error_message = _("Trim failed. %s\n").printf (e.message);
                critical (error_message);
                trim_failed (error_message);
            }
            trim_state = TrimState.IDLE;
        }

        private string sanitize (string uri) {
            /*
               Removing escape characters and replacing them with spaces
               as ffmpeg doesn't work with normal escaped uris
            */
            var uri_with_spaces = Uri.unescape_string (uri);
            return uri_with_spaces;
        }
    }
}
