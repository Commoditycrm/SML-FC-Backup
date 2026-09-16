/**
 * @author RadialSpark
 * @date 05-01-2018
 * @description Parses XML responses from TMS into BOL__c SObjects
 * @changelog
	06-12-2018 - Bradley Wong - created
 */
public class DateTimeUtility {
	/**
	 * @description Formats DateTime values as 2018-06-04T12:00:00Z yyyy-mm-ddThh:mm:ssZ
	 * @param {DateTime} Apex DateTime value
	 */
	public static String toString(DateTime inputTime) {
		String[] timeArray = inputTime
			.format('yyyy-MM-dd\'T\'hh:mm:ssZ')
			.split('-');

		return timeArray[0] + '-' + timeArray[1] + '-' + timeArray[2] + 'Z';
	}

	// /**
	//  * @description Parse TMS dates to Apex DateTime values 
	//  * @param {String} tmsDate (yyyy-MM-ddThh:mm:ssZ)
	//  */
	// public static DateTime toDateTime(String tmsDate) {
	// 	List<String> splitTmsDate = tmsDate.split('T');

	// 	List<String> dateComponents = splitTmsDate[0].split('-');
	// 	List<String> timeComponents = splitTmsDate[1].split('Z')[0].split(':');

	// 	return DateTime.newInstance(
	// 		Integer.valueOf(dateComponents[0]), 
	// 		Integer.valueOf(dateComponents[1]), 
	// 		Integer.valueOf(dateComponents[2]), 
	// 		Integer.valueOf(timeComponents[0]), 
	// 		Integer.valueOf(timeComponents[1]), 
	// 		Integer.valueOf(timeComponents[2])
	// 	);
	// }
}