namespace Trimmer {
    public class TrimmingDialog : Granite.Dialog {
        public string filename {get; set;}

        construct {
            width_request = 400;
            var label = new Gtk.Label ("Trimming %s".printf (filename));
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);
            var spinner = new Gtk.Spinner () {
                active = true,
                height_request = 32
            };

            var layout = new Gtk.Grid () {
                margin = 6,
                row_spacing = 10,
                halign = Gtk.Align.CENTER
            };

            layout.attach (spinner, 1, 1, 1, 1);
            layout.attach (label, 1, 2, 1, 1);

            layout.show_all ();
            get_content_area ().add (layout);

            notify ["filename"].connect (() => {
                label.set_text ("Trimming %s".printf (filename));
            });
        }
    }
}
