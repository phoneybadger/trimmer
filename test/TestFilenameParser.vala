namespace Trimmer {
    void main (string[] args) {
        Test.init (ref args);
        add_tests ();
        Test.run ();
    }

    void add_tests () {
        Test.add_func ("/basename", test_get_basename);
        Test.add_func ("/extension", test_get_extension);
    }

    void test_get_basename () {
        var map = new Gee.HashMap<string,string> ();
        map.set ("file:///home/video", "video");
        map.set ("file:///home/user name/Downloads/video", "video");
        map.set ("file:///home/user-name/video.mp4", "video.mp4");
        map.set ("file:///folder/video file.mp4", "video file.mp4");
        foreach (var entry in map.entries) {
            var uri = entry.key;
            var basename = entry.value;
            assert_true (Utils.get_basename (uri) == basename);
        }
    }

    void test_get_extension () {
        var map_with_ext = new Gee.HashMap<string,string> ();
        map_with_ext.set ("file:///video.mp4", "mp4");
        map_with_ext.set ("file:///video.file.mp4", "mp4");
        map_with_ext.set ("file:///video.2018 [1080p].m4v", "m4v");
        map_with_ext.set ("file:///video-name.avi", "avi");
        map_with_ext.set ("file:///directory name/video-name.avi", "avi");
        foreach (var entry in map_with_ext.entries) {
            try {
                var uri = entry.key;
                var basename = entry.value;
                assert_true (Utils.get_file_extension (uri) == basename);
            } catch (Utils.NoExtensionError e) {
                // all these should have an extension. hence the error shouldn't
                // occur
                Test.fail ();
            }
        }
        
        string[] uris_without_extensions = {
            "file:///video",
            "file:///directory name/file",
            "file:///home/user-name/file name",
            "file:///home/user-name/file-name",
        };
        foreach (var uri in uris_without_extensions) {
            try {
                Utils.get_file_extension (uri);
            } catch (Utils.NoExtensionError e){
                continue;
            }
            /* all the cases should cause an error so if the error is not 
            caused the test has failed */
            /* there must be a better way to do this */
            Test.fail ();
        }
    }
}

