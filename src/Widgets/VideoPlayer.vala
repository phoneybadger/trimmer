/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
namespace Trimmer {
    public class VideoPlayer : GtkClutter.Embed {
        /* TODO: port over to using a more straight forward implementation
        using Gtk.Picture or Gtk.Video when elementary opens up for GTK 4*/

        public ClutterGst.Playback playback;
        public unowned Trimmer.TrimView trim_view {get; set;}
        public signal void video_loaded (double video_duration, string uri);

        public VideoPlayer (Trimmer.TrimView trim_view) {
            Object (
                trim_view : trim_view
            );
        }

        construct {
            playback = new ClutterGst.Playback () {
                seek_flags = ClutterGst.SeekFlags.ACCURATE
            };
            // loop video
            playback.eos.connect (()=>{
                playback.progress = 0;
                playback.playing = true;
            });

            // when new video loaded
            playback.notify ["duration"].connect (() => {
                // the duration seems to momentarily becomes zero before the video is loaded
                if (playback.duration != 0) {
                    video_loaded (playback.duration, playback.uri);
                }
            });

            playback.notify ["playing"].connect (() => {
                trim_view.update_play_button_icon ();
            });

            // update seek bar in sync with video progress
            playback.notify ["progress"].connect (() => {
                trim_view.timeline.playback_progress = playback.progress;
            });

            var stage = this.get_stage ();
            stage.background_color = {0, 0, 0, 0};

            var video_actor = new Clutter.Actor ();
            var aspect_ratio = new ClutterGst.Aspectratio ();

            aspect_ratio.paint_borders = false;
            aspect_ratio.player = playback;
            video_actor.content = aspect_ratio;

            video_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 0));
            video_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 0));

            stage.add_child (video_actor);
        }

        public void play_video (string uri) {
            playback.uri = uri;
            playback.playing = true;
        }

        public void toggle_play_pause () {
            playback.playing = !playback.playing;
        }

        public void stop_and_destroy () {
            playback.playing = false;
            playback.uri = null;
        }
    }
}
