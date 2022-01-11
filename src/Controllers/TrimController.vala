namespace Trimmer.Controllers {
    public class TrimController : GLib.Object {
        private const double DEFAULT_START = 1.0/4.0;
        private const double DEFAULT_END = 3.0/4.0;

        private int _trim_start;
        private int _trim_end;
        private double _duration;

        public int trim_start {
            get {
                return _trim_start;
            }
            set {
                _trim_start = value;
            }
        }

        public int trim_end {
            get {
                return _trim_end;
            }
            set {
                _trim_end = value;
            }
        }

        public double duration {
            get {
                return _duration;
            } set {
                _duration = value;
            }
        }

        public string video_uri;

        construct {
            duration = 0;

            notify ["duration"].connect (() => {
                trim_start = (int) (DEFAULT_START * duration);
                trim_end = (int) (DEFAULT_END * duration);
            });
        }

        public void trim_video () {
            var output_uri = "file:///home/adithyankv/Videos/test.mp4";
            string[] cmd_args = {
                "ffmpeg",
                "-i",   //input
                video_uri,
                "-ss",
                Granite.DateTime.seconds_to_time (trim_start),
                "-to",
                Granite.DateTime.seconds_to_time (trim_end),
                "-c:v copy",        // copy video without reencoding
                "-c:a copy",        // copy audio without reencoding
                output_uri
            };

            try {
                Process.spawn_command_line_async (string.joinv (" ", cmd_args));
            } catch (SpawnError e) {
                print ("Error:%s", e.message);
            }
        }
    }
}
