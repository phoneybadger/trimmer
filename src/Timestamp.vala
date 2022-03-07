namespace Trimmer {
    public class Timestamp {
        public string text {get; set;}
        private Regex timestamp_regex;

        public Timestamp () {
            try {
                // Regex for hours:minutes:seconds
                /*

                ^                                   start of string
                (
                    ([0-9]+:)?                      optionally match hours:
                    ([0-5]?[0-9]:)                  match mm: or m: with mm < 60, m <10
                )?                                  optionally match hours:mm
                ([0-5]?[0-9])                       match ss or s. ss < 60, s < 10
                $                                   end of string

                */
                timestamp_regex = new Regex ("^(([0-9]+:)?([0-5]?[0-9]:))?([0-5]?[0-9])$");
            } catch (RegexError e) {
                critical (e.message);
            }
        }

        public bool is_valid () {
            if (text == null) {
                return false;
            }
            return timestamp_regex.match (text);
        }

        public int convert_to_seconds () {
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
                    critical ("Error parsing timestamp, timestamp:%s", text);
                    break;
            }
            return hours * 3600 + minutes * 60 + seconds;
        }

        public string format () {
            var seconds = convert_to_seconds ();
            return Granite.DateTime.seconds_to_time (seconds);
        }
    }
}
