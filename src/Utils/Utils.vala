/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adithyan K V <adithyankv@protonmail.com>
 */
namespace Trimmer.Utils {
    int max (int a, int b) {
        if (a > b) {
            return a;
        }
        else {
            return b;
        }
    }

    errordomain NoExtensionError {
        NO_EXTENSION
    }

    string get_file_extension (string uri) throws NoExtensionError {
        /* assuming the piece of text after the last "." is the file 
           extension. Not foolproof but must be good enough for now */
        // TODO: should handle case where filename has a "." but no file
        // extension. eg. "video.1.1"
        var basename = get_basename (uri);
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
        var basename = get_basename (uri);
        var name_parts = basename.split (".");
        var filename = string.joinv (".", name_parts [0:name_parts.length - 1]);
        return filename;
    }

    string get_basename (string uri) {
        /* assuming the text after the last forward slash is the name of 
        the file. As slashes are not allowed in file names, this should hold
        true */
        var parts = uri.split ("/");
        var basename = parts [parts.length - 1];
        return basename;
    }
}
