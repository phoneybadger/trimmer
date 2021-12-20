namespace Trimmer {
    public class TimeStampEntry : Granite.ValidatedEntry {
        private Regex timestamp_regex = null;

        public TimeStampEntry () {
            Object (
                // initially set to 00:00:00
                text : Granite.DateTime.seconds_to_time (0)
                );
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
        }

        public void check_bounds (double min, double max) {
            var time = timestamp_in_seconds ();
            // snap back to within bounds if out of bounds
            if (time < min) {
                text = Granite.DateTime.seconds_to_time ((int) min);
            } else if (time > max) {
                text = Granite.DateTime.seconds_to_time ((int) max);
            }
        }


        public int timestamp_in_seconds () {
            
            var parsed_time = text.split (":");
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
