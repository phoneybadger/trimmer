namespace Trimmer {
    public class TimeStampEntry : Granite.ValidatedEntry {
        private Regex timestamp_regex;

        public int _min_time;
        public int min_time {
            get {
                return _min_time;
            }
            set {
                _min_time = value;
            }
        }

        private int _max_time;
        public int max_time {
            get {
                return _max_time;
            }
            set {
                _max_time = value;
            }
        }

        private int _time;
        public int time {
            get {
                return _time;
            }
            set {
                _time = value;
            }
        }

        construct {
            notify ["time"].connect (() => {
                text = Granite.DateTime.seconds_to_time (time);
            });

            changed.connect (() => {
                validate ();
            });

            activate.connect (() => {
                if (is_valid) {
                    time = convert_timestamp_to_seconds(text);
                    // formatting it better
                    text = Granite.DateTime.seconds_to_time(time);
                }
            });
        }

        private bool is_valid_timestamp(string timestamp) {
            return timestamp_regex.match(text);
        }

        private bool is_within_bounds(string timestamp) {
            var time = convert_timestamp_to_seconds(timestamp);
            return (time >= min_time && time <= max_time);
        }

        private void validate() {
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

            if (is_valid_timestamp(text)) {
                if (is_within_bounds(text)) {
                    is_valid = true;
                } else {
                    print("time:%d min:%d max:%d\n", time, min_time, max_time);
                    is_valid = false;
                }
            } else {
               is_valid = false;
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
