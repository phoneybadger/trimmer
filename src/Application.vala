namespace Trimmer {
    public class Application : Gtk.Application {
        public Application () {
            Object (
                application_id : "com.github.adithyankv.trimmer",
                flags : ApplicationFlags.FLAGS_NONE
                );
        }

        protected override void activate () {
            var window = new Trimmer.Window (this);
            window.show_all ();
        }
    }
}
