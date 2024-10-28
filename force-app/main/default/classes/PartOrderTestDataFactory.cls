@isTest
public class PartOrderTestDataFactory {
	public static Part_Order__c createPartOrder(
		String name,
		String trackingNumber,
		Date expectedArrival,
		String status,
		Boolean isInsert
	) {
		Part_Order__c partOrder = new Part_Order__c(
			Name = name,
			Tracking_Number__c = trackingNumber,
			Expected_Arrival__c = expectedArrival,
			Status__c = status
		);

		if (isInsert) {
			insert partOrder;
		}
		return partOrder;
	}

}