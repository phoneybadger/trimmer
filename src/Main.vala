/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
public int main (string[] args) {
    // Initializes clutter and gstreamer for video playback
    var err = GtkClutter.init (ref args);
    if (err != Clutter.InitError.SUCCESS) {
        error ("Could not initialize clutter! %s", err.to_string ());
    }
    Gst.init (ref args);

    var app = new Trimmer.Application ();
    int status = app.run ();

    return status;
}
