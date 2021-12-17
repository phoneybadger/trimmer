namespace Trimmer {
    public class VideoPlayer : GtkClutter.Embed {

        public ClutterGst.Playback playback;

        construct {
            playback = new ClutterGst.Playback () {
                seek_flags = ClutterGst.SeekFlags.ACCURATE
            };
            // loop video
            playback.eos.connect (()=>{
                playback.progress = 0;
                playback.playing = true;
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
        
        public void load_and_play_video (string uri) {
            playback.uri = uri;
            playback.playing = true;
        }
    }
}