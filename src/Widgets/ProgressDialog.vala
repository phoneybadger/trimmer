/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
namespace Trimmer {
    public class ProgressDialog : Granite.Dialog {
        public string filename {get; set;}

        construct {
            width_request = 400;
            set_modal (true);
            string progress_message;
            var label = new Gtk.Label (progress_message);
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
                ///TRANSLATORS: where %s is the input video file name
                progress_message = _("Trimming %s".printf (filename));
                label.set_text (progress_message);
            });
        }
    }
}
