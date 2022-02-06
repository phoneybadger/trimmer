namespace Trimmer.Controllers {
    public class TrimController : GLib.Object {
        private const double DEFAULT_START = 1.0/4.0;
        private const double DEFAULT_END = 3.0/4.0;

        // all values in seconds
        private int _trim_start_time;
        private int _trim_end_time;
        private double _duration;

        public int trim_start_time {
            get {
                return _trim_start_time;
            }
            set {
                _trim_start_time = value;
            }
        }

        public int trim_end_time {
            get {
                return _trim_end_time;
            }
            set {
                _trim_end_time = value;
            }
        }

        public double duration {
            get {
                return _duration;
            } set {
                _duration = value;
            }
        }

        private bool _is_valid_trim;
        public bool is_valid_trim {
            get {
                return _is_valid_trim;
            } set {
                _is_valid_trim = value;
            }
        }

        public string video_uri;

        construct {
            notify ["duration"].connect (() => {
                trim_start_time = (int) (DEFAULT_START * duration);
                trim_end_time = (int) (DEFAULT_END * duration);
            });
        }
    }
}
