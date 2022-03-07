namespace Trimmer {
    void main (string[] args) {
        Test.init (ref args);
        add_tests ();
        Test.run ();
    }

    void add_tests () {
        Test.add_func ("/validity", test_timestamp_validity);
        Test.add_func ("/convert_to_seconds", test_seconds_conversion);
    }

    void test_timestamp_validity () {
        var timestamp = new Timestamp ();
        string[] valid_timestamps = {
            "0",
            "0:00",
            "1:00",
            "01:00",
            "1:59",
            "01:59",
            "12:59",
            "1:00:00",
            "01:00:00",
            "12:00:00",
            "133:11:11"
        };
        foreach (var valid_timestamp in valid_timestamps) {
            timestamp.text = valid_timestamp;
            assert_true (timestamp.is_valid ());
        }

        string[] invalid_timestamps = {
            "a",
            "a:10",
            ":10",
            "60",
            "111:00",
            "111",
            "HH:MM",
            "61:00",
            "trimmer",
            ":00:00",
            "?00",
            "0::00"
        };
        foreach (var invalid_timestamp in invalid_timestamps) {
            timestamp.text = invalid_timestamp;
            assert_false (timestamp.is_valid ());
        }
    }

    void test_seconds_conversion () {
        var timestamp = new Timestamp ();
        var timestamp_to_seconds_map = new Gee.HashMap<string, int> ();
        timestamp_to_seconds_map.set ("0:00", 0);
        timestamp_to_seconds_map.set ("33", 33);
        timestamp_to_seconds_map.set ("1:30", 90);
        timestamp_to_seconds_map.set ("10:00", 600);
        timestamp_to_seconds_map.set ("1:10:00", 4200);
        foreach (var entry in timestamp_to_seconds_map.entries) {
            timestamp.text = entry.key;
            var seconds = entry.value;
            assert_true (timestamp.convert_to_seconds () == seconds);
        }
    }
}
