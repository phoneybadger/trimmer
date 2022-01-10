namespace Trimmer.Controllers {
    public class TrimController : GLib.Object {
        private const double DEFAULT_START = 1.0/3.0;
        private const double DEFAULT_END = 2.0/3.0;

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

            notify ["trim-start"].connect (() => {
                print ("%d\n", trim_start);
            });
        }
    }
}
