namespace Trimmer {
    public class VideoPlayer : GtkClutter.Embed {

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

            // update seek bar in sync with video progress
            playback.notify ["duration"].connect (() => {
                trim_view.seeker.playback_duration = playback.duration;
            });
            playback.notify ["progress"].connect(() => {
                trim_view.seeker.playback_progress = playback.progress;
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
    }
}
