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
    }
}
