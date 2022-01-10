namespace Trimmer.Controllers {
    public class TrimController : GLib.Object {
        public int trim_start;
        public int trim_end;
        public string video_uri;
        public int clip_duration;

        public TrimController () {

        }

        construct {
            print ("something");
        }
    }
}
