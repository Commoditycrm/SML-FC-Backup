@isTest
public class CaseTestDataFactory {
	
	public static Case createCase(
		String status,
		String origin,
		Id partOrderId,
		Boolean isInsert
	)	{

		Case testCase = new Case(
			Status = status,
			Origin = origin,
			Part_Order__c = partOrderId
		);

		if (isInsert) {
			insert testCase;
		}
		return testCase;
	}
}