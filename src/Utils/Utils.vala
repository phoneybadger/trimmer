namespace Trimmer.Utils {
    int max (int a, int b) {
        if (a > b) {
            return a;
        }
        else {
            return b;
        }
    }

    int convert_timestamp_to_seconds (string timestamp) {
        var parsed_time = timestamp.split (":");
        var hours = 0;
        var minutes = 0;
        var seconds = 0;

        // TODO: there must be a cleaner way to do this
        switch (parsed_time.length) {
            case 3:
                hours = int.parse (parsed_time [0]);
                minutes = int.parse (parsed_time [1]);
                seconds = int.parse (parsed_time [2]);
                break;
            case 2:
                minutes = int.parse (parsed_time [0]);
                seconds = int.parse (parsed_time [1]);
                break;
            case 1:
                seconds = int.parse (parsed_time [0]);
                break;
            default:
                critical ("Error parsing timestamp, timestamp:%s", timestamp);
                break;
        }
        return hours * 3600 + minutes * 60 + seconds;
    }

    errordomain NoExtensionError {
        NO_EXTENSION
    }

    string get_file_extension (string uri) throws NoExtensionError {
        /* assuming the piece of text after the last "." is the file 
           extension. Not foolproof but must be good enough for now */
        var file = File.new_for_uri (uri);
        var basename = file.get_basename ();
        var name_parts = basename.split (".");
        if (name_parts.length < 2) {
            debug ("couldn't find file extension");
            throw new NoExtensionError.NO_EXTENSION ("No extension found");
        } else {
            var extension = name_parts [name_parts.length - 1];
            return extension;
        }
    }

    string get_filename (string uri) {
        var file = File.new_for_uri (uri);
        var basename = file.get_basename ();
        var name_parts = basename.split (".");
        var filename = string.joinv (".", name_parts [0:name_parts.length - 1]);
        return filename;
    }
}
