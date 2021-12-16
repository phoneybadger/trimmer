namespace Trimmer {
    public class WelcomeView : Granite.Widgets.Welcome {
        public Trimmer.Window window {get; set;}

        public WelcomeView (Trimmer.Window window) {
            Object (
                title : "No videos open",
                subtitle : "Open a video to trim it",
                window : window
                );
        }

        construct {
            append ("folder-videos", "Open video", "Open a video file");

            activated.connect((index)=>{
                switch (index) {
                    case 0:
                        window.actions.lookup_action (Window.ACTION_OPEN).activate (null);
                }
            });
        }
    }
}
