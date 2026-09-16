public class TimestampConverter {
    public static DateTime convertUnixTimestampToGMT(Long unixTimestamp) {
        // Unix timestamp is in seconds, but DateTime.newInstance() expects milliseconds
        DateTime dt = DateTime.newInstance(unixTimestamp * 1000);
        // Convert the DateTime to GMT String
      //  String gmtString = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
      //  DateTime tsTime = Datetime.valueof(gmtString);
        return dt;
    }
}