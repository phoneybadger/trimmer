/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
namespace Trimmer {
    public class MessageArea : Gtk.Grid {
        construct {
            orientation = Gtk.Orientation.VERTICAL;
        }

        public void add_message (Gtk.MessageType type, string message) {
            var message_bar = new Gtk.InfoBar () {
                message_type = type,
                show_close_button = true,
            };
            var message_label = new Gtk.Label (message) {
                ellipsize = Pango.EllipsizeMode.END
            };
            message_bar.get_content_area ().add (message_label);
            message_bar.response.connect (() => {
                message_bar.hide ();
                remove (message_bar);
            });

            add (message_bar);
            show_all ();
        }
    }
}
