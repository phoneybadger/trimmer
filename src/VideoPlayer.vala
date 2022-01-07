namespace Trimmer {
    public class VideoPlayer : GtkClutter.Embed {
        /* TODO: port over to using a more straight forward implementation
        using Gtk.Picture or Gtk.Video when elementary opens up for GTK 4*/

        public ClutterGst.Playback playback;
        public unowned Trimmer.TrimView trim_view {get; set;}

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
                trim_view.timeline.playback_duration = playback.duration;
                // set end entry to end of clip duration by default
                trim_view.end_entry.text = Granite.DateTime.seconds_to_time ((int) playback.duration);
            });

            // update seek bar in sync with video progress
            playback.notify ["progress"].connect(() => {
                if (!trim_view.timeline.is_grabbing) {
                    trim_view.timeline.playback_progress = playback.progress;
                }
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
