namespace Trimmer.Utils{
    public int max(int a, int b) {
        if (a > b) {
            return a;
        }
        else {
            return b;
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
