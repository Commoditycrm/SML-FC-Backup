/**
 * @author Connor Zint
 * @date 01/18/2018
 * @description Trigger Service Methods on Part_Order__c
 */
public without sharing class PartOrderService extends TriggerHandler {
	
	@TestVisible
	private List<Part_Order__c> triggerNew;

    /**
     * @description Standard constructor -- sets class variables
     * @param records wrapped trigger context data structures
     */
    public PartOrderService(TriggerRecordWrapper records) {
        super(records);
		triggerNew = (List<Part_Order__c>)records.getTriggerNew();
    }

    public override void doAfterInsert() {
		
		// call service methods
		createOrderCase();
	}


	/**
     * @description create a case when a new part order is created
     */
	@TestVisible
	private void createOrderCase() {
		RecordType caseRecordTypeOrder = [
			SELECT Id, DeveloperName 
			FROM RecordType 
			WHERE DeveloperName = 'Order'
			AND sobjecttype = 'Case'
			LIMIT 1
		];

		List<Case> newCaseList = new List<Case>();

		for (Part_Order__c partOrder : triggerNew) {

			Case newCase = new Case(
				RecordTypeId = caseRecordTypeOrder.Id,
				Part_Order__c = partOrder.Id,
				Origin = 'Automated Order',
				Status = 'New'
			);

			newCaseList.add(newCase);
		}

		insert newCaseList;
	}

}