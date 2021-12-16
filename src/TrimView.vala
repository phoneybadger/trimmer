namespace Trimmer {
    public class TrimView : Gtk.Box {
        public ClutterGst.Playback playback;
        public TrimView () {
            Object (
                orientation: Gtk.Orientation.VERTICAL,
                spacing: 0
            );
        }

        construct {
            var file_uri = "file:///home/adithyankv/Downloads/sprite_fright.mp4";

            playback = new ClutterGst.Playback ();
            playback.eos.connect (()=>{
                playback.progress = 0;
                playback.playing = true;
            });
            playback.seek_flags = ClutterGst.SeekFlags.ACCURATE;

            var clutter = new GtkClutter.Embed ();

            var stage = clutter.get_stage ();
            stage.background_color = {0, 0, 0, 0};

            var video_actor = new Clutter.Actor ();
            var aspect_ratio = new ClutterGst.Aspectratio ();

            aspect_ratio.paint_borders = false;
            aspect_ratio.player = playback;
            video_actor.content = aspect_ratio;

            video_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 0));
            video_actor.add_constraint (new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 0));

            stage.add_child (video_actor);

            playback.uri = file_uri;
            add (clutter);
        }
    }
}
