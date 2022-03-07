/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
namespace Trimmer {
    public class WelcomeView : Granite.Widgets.Welcome {
        public Trimmer.Window window {get; set;}

        public WelcomeView (Trimmer.Window window) {
            Object (
                title : _("No videos open"),
                subtitle : _("Open a video to trim it"),
                window : window
                );
        }

        construct {
            append ("folder-videos", _("Open video"), _("Open a video file"));
            append ("system-help", _("Help"), _("Having trouble? Get help and report issues"));

            activated.connect ((index)=>{
                switch (index) {
                    case 0:
                        window.actions.lookup_action (Window.ACTION_OPEN).activate (null);
                        break;
                    case 1:
                        // Redirect to github page
                        try {
                            AppInfo.launch_default_for_uri_async.begin (
                                "https://github.com/phoneybadger/trimmer",
                                null
                            );
                        } catch (Error e) {
                            warning (e.message);
                        }
                        break;
                }
            });
        }
    }
}
