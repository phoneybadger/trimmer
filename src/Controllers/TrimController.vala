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
    }
}
