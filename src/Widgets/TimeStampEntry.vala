namespace Trimmer {
    public class TimeStampEntry : Gtk.Entry {
        private Regex timestamp_regex;

        private bool _is_valid;
        public bool is_valid {
            get {
                return _is_valid;
            } set {
                _is_valid = value;
            }
        }

        private int _time;
        public int time {
            get {
                return _time;
            } set {
                _time = value;
            }
        }

        construct {
            setup_timestamp_regex ();

            notify ["is-valid"].connect (() => {
                update_style ();
            });

            notify ["time"].connect (() => {
                text = Granite.DateTime.seconds_to_time (time);
            });

            activate.connect (() => {
                if (is_valid) {
                    time = convert_timestamp_to_seconds (text);
                    text = Granite.DateTime.seconds_to_time (time); // better formatting
                }
            });

            changed.connect (validate);
        }

        public void validate () {
            if (timestamp_regex.match (text)) {
                is_valid = true;
            } else {
                is_valid = false;
            }
        }

        public void update_style () {
            /* change UI style to invalid or valid styles depending on state */
            var style_context = get_style_context ();
            if (is_valid) {
                secondary_icon_name = "process-completed-symbolic";
                style_context.remove_class (Gtk.STYLE_CLASS_ERROR);
            } else {
                secondary_icon_name = "process-error-symbolic";
                style_context.add_class (Gtk.STYLE_CLASS_ERROR);
            }
        }

        private void setup_timestamp_regex () {
            try {
                // Regex for HH:MM:SS taken from
                // https://stackoverflow.com/questions/8318236/regex-pattern-for-hhmmss-time-string
                // 
                // ^                   # Start of string
                // (?:                 # Try to match...
                //  (?:                #  Try to match...
                //   ([01]?[0-9]|2[0-3]): #   HH:
                //  )?                 #  (optionally).
                //  ([0-5]?[0-9]):        #  MM: (required)
                // )?                  # (entire group optional, so either HH:MM:, MM: or nothing)
                // ([0-5]?[0-9])          # SS (required)
                // $                   # End of string
                timestamp_regex = new Regex ("^(?:(?:([01]?[0-9]|2[0-3]):)?([0-5]?[0-9]):)?([0-5]?[0-9])$");
            } catch (RegexError e) {
                critical (e.message);
            }
        }
        
        private int convert_timestamp_to_seconds (string timestamp) {
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
                    critical ("Error parsing timestamp");
                    break;
            }
            return hours * 60 + minutes * 60 + seconds;
        }
    }
}
