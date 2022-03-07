/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
namespace Trimmer {
    public class TimeStampEntry : Gtk.Entry {
        public bool is_valid {get; set;}
        public int time {get; set;}
        public Timestamp timestamp;

        construct {
            timestamp = new Timestamp ();

            notify ["is-valid"].connect (() => {
                update_style ();
            });

            activate.connect (() => {
                if (timestamp.is_valid ()) {
                    text = timestamp.format ();
                }
            });

            focus_out_event.connect (() => {
                activate ();
            });

            changed.connect (() => {
                timestamp.text = text;
                if (timestamp.is_valid ()) {
                    is_valid = true;
                    time = timestamp.convert_to_seconds ();
                } else {
                    is_valid = false;
                }
            });

            notify ["time"].connect (() => {
                /* only change the text if the user is not actively typing.
                This prevents the text from changing under the user on every
                keystroke */
                if (!has_focus) {
                    text = Granite.DateTime.seconds_to_time (time);
                }
            });
        }

        public void update_style () {
            /* change UI style to invalid or valid styles depending on state */
            var style_context = get_style_context ();
            if (is_valid) {
                secondary_icon_name = "process-completed-symbolic";
                style_context.remove_class (Gtk.STYLE_CLASS_ERROR);
            } else {
                secondary_icon_name = "process-error-symbolic";
                style_context.add_class (Gtk.STYLE_CLASS_ERROR);
            }
        }
    }
}
