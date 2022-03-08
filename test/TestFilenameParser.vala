namespace Trimmer {
    void main (string[] args) {
        Test.init (ref args);
        add_tests ();
        Test.run ();
    }

    void add_tests () {
        Test.add_func ("/basename", test_get_basename);
        Test.add_func (
            "/extension/valid_extensions",
            test_get_extension_for_valid_extensions
        );
        Test.add_func (
            "/extension/no_extensions",
            test_get_extension_for_no_extensions
        );
        Test.add_func (
            "/extension/invalid_extensions",
            test_get_extension_for_invalid_extensions
        );
        Test.add_func (
            "/filename",
            test_get_filename
        );
    }

    void test_get_basename () {
        var parser = new Utils.FilenameParser ();
        var map = new Gee.HashMap<string,string> ();
        map.set ("file:///home/video", "video");
        map.set ("file:///home/user name/Downloads/video", "video");
        map.set ("file:///home/user-name/video.mp4", "video.mp4");
        map.set ("file:///folder/video file.mp4", "video file.mp4");
        foreach (var entry in map.entries) {
            var uri = entry.key;
            var basename = entry.value;
            assert_true (parser.get_basename (uri) == basename);
        }
    }

    void test_get_extension_for_valid_extensions () {
        var parser = new Utils.FilenameParser ();
        var map_with_ext = new Gee.HashMap<string,string> ();
        // testing different basic extensions
        map_with_ext.set ("file:///video.mp4", "mp4");
        map_with_ext.set ("file:///video.mov", "mov");
        map_with_ext.set ("file:///video.avi", "avi");
        // testing names with dots
        map_with_ext.set ("file:///video.file.mp4", "mp4");
        map_with_ext.set ("file:///video.2018 [1080p].m4v", "m4v");
        map_with_ext.set ("file:///video-name.avi", "avi");
        // testing names with spaces on different extensions
        map_with_ext.set ("file:///directory name/video name.avi", "avi");
        map_with_ext.set ("file:///directory name/video-name.mkv", "mkv");
        foreach (var entry in map_with_ext.entries) {
            try {
                var uri = entry.key;
                var basename = entry.value;
                assert_true (parser.get_file_extension (uri) == basename);
            } catch (Utils.NoExtensionError e) {
                // all these should have an extension. hence the error shouldn't
                // occur
                Test.fail ();
            }
        }
    }

    void test_get_extension_for_no_extensions () {
        var parser = new Utils.FilenameParser ();
        string[] uris_without_extensions = {
            "file:///video",
            "file:///directory name/file",
            "file:///home/user-name/file name",
            "file:///home/user-name/file-name",
            // testing files with "." followed by invalid extensions
            "file:///home/file.notanextension",
            "file:///home/file.mp9"
        };
        foreach (var uri in uris_without_extensions) {
            try {
                parser.get_file_extension (uri);
            } catch (Utils.NoExtensionError e) {
                continue;
            }
            /* all the cases should cause an error so if the error is not
            caused the test has failed */
            /* there must be a better way to do this */
            Test.fail ();
        }
    }

    void test_get_extension_for_invalid_extensions () {
        var parser = new Utils.FilenameParser ();
        string[] uris_without_extensions = {
            "file:///home/file.notanextension",
            "file:///home/file.mp9"
        };
        foreach (var uri in uris_without_extensions) {
            try {
                parser.get_file_extension (uri);
            } catch (Utils.NoExtensionError e) {
                continue;
            }
            Test.fail ();
        }
    }

    void test_get_filename () {
        var parser = new Utils.FilenameParser ();
        // filename with extensions
        assert_true (parser.get_filename ("file:///home/video.mp4") == "video");
        // filename without extensions
        assert_true (parser.get_filename ("file///video") == "video");
        // filename with spaces
        assert_true (parser.get_filename ("file///file name") == "file name");
        // filename in path with spaces
        assert_true (parser.get_filename ("file///a b c/video") == "video");
        // filename with dots
        assert_true (parser.get_filename ("file///file.name") == "file.name");
    }
}
