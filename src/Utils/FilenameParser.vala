namespace Trimmer.Utils {
    public errordomain NoExtensionError {
        NO_EXTENSION
    }

    public class FilenameParser {
        private Gee.HashSet<string> common_extensions;

        public FilenameParser () {
            // common video extensions taken from wikipedia
            common_extensions = new Gee.HashSet<string> ();
            string[] extensions = {
                "webm",
                "mkv",
                "flv",
                "vob",
                "ogv",
                "ogg",
                "drc",
                "avi",
                "mov",
                "qt",
                "wmv",
                "yuv",
                "rm",
                "rmvb",
                "viv",
                "asf",
                "amv",
                "m4p",
                "mp4",
                "m4v",
                "mpg",
                "mp2",
                "mpeg",
                "mpe",
                "mpv",
                "3gp",
                "mxf"
            };
            foreach (var extension in extensions) {
                common_extensions.add (extension);
            }
        }

        public string get_file_extension (string uri) throws NoExtensionError {
            /* assuming the piece of text after the last "." is the file 
               extension. Not foolproof but must be good enough for now */
            var uri_with_spaces = Uri.unescape_string (uri);
            var basename = get_basename (uri_with_spaces);
            var name_parts = basename.split (".");
            if (name_parts.length < 2) {
                debug ("couldn't find file extension");
                throw new NoExtensionError.NO_EXTENSION ("No extension found");
            } else {
                var extension = name_parts [name_parts.length - 1];
                if (common_extensions.contains (extension)) {
                    return extension;
                } else {
                    debug ("Invalid extension");
                    throw new NoExtensionError.NO_EXTENSION ("Invalid extension");
                }
            }
        }

        public string get_filename (string uri) {
            var uri_with_spaces = Uri.unescape_string (uri);
            var basename = get_basename (uri_with_spaces);
            try {
                get_file_extension (uri_with_spaces);
            } catch (NoExtensionError e) {
                return basename;
            }
            var name_parts = basename.split (".");
            if (name_parts.length == 1) {
                return basename;
            }
            var filename = string.joinv (".", name_parts [0:name_parts.length - 1]);
            return filename;
        }

        public string get_basename (string uri) {
            /* assuming the text after the last forward slash is the name of 
            the file. As slashes are not allowed in file names, this should hold
            true */
            var uri_with_spaces = Uri.unescape_string (uri);
            var parts = uri_with_spaces.split ("/");
            var basename = parts [parts.length - 1];
            return basename;
        }
    }
}
