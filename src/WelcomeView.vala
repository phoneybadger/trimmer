namespace Trimmer {
    public class WelcomeView : Granite.Widgets.Welcome {
        public WelcomeView () {
            Object (
                title : "No videos open",
                subtitle : "Open a video to trim it"
                );
        }

        construct {
            append ("folder-videos", "Open video", "Open a video file");

            activated.connect((index)=>{
                switch (index) {
                    case 0:
                        print("something");
                }
            });
        }
    }
}
