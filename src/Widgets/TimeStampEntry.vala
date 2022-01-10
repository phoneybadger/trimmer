namespace Trimmer {
    public class TimeStampEntry : Granite.ValidatedEntry {
        private int _time;
        private Regex timestamp_regex = null;
        public int time {
            get {
                return _time;
            }
            set {
                _time = value;
            }
        }

        construct {
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

            regex = timestamp_regex;

            notify ["time"].connect (() => {
                text = Granite.DateTime.seconds_to_time (time);
            });

            activate.connect (() => {
                if (is_valid) {
                    time = convert_timestamp_to_seconds (text);
                }
            });
        }

        public int convert_timestamp_to_seconds (string timestamp) {
            
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
