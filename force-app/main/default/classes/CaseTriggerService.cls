/**
 * @author Connor Zint
 * @date 01/17/2018
 * @description Implementation of a trigger handler for the Case Object
 */
public with sharing class CaseTriggerService extends TriggerHandler {
	@TestVisible
	private List<Case> triggerNew;
	@TestVisible
	private Map<Id, Case> oldMap;
	
	/**
     * @description Standard constructor -- sets class variables
     * @param records wrapped trigger context data structures
     */
	public CaseTriggerService(TriggerRecordWrapper records) {
		super(records);
		triggerNew = (List<Case>)records.getTriggerNew();
		oldMap = (Map<Id, Case>)records.getOldMap();
	}

	public override void doBeforeInsert() {

		// call service methods
		checkPartOrderDeliveredOnClosedCase();
	}


    public override void doBeforeUpdate() {

		// call service methods
		checkPartOrderDeliveredOnClosedCase();
    }

	/**
	 * @description Set Has_Been_Delivered on related Part_Order to true
	 				when the case has been closed
	 * @param  List<Case> triggerNew list of new or updated Case records
	 * @param  Map<Id,Case> oldMap map of old records
	 */ 
	@TestVisible
	private void checkPartOrderDeliveredOnClosedCase () {

		List<Id> partOrderIds = new List<Id>();
		
		for (Case newCase : triggerNew) {
			
			// reference the old case for update or
			// create a fake old case to reference if insert
			Case oldCase = (oldMap != null) ? oldMap.get(newCase.Id) : new Case();

			// if the status changed and is 'Closed' add the Part_Order id
			// to the list of ids we need to get
			if (
				newCase.Status != oldCase.Status &&
				newCase.Status == 'Closed'
			) {
				partOrderIds.add(newCase.Part_Order__c);
			}
		}

		if (!partOrderIds.isEmpty()) {

			// we only need to update the part orders that
			// have not been 'Delivered'
			List<Part_Order__c> partOrders = [
				SELECT
					Id,
					Status__c
				FROM Part_Order__c
				WHERE Id IN :partOrderIds
				AND Status__c != 'Delivered'
			];

			if (!partOrders.isEmpty()) {

				List<Part_Order__c> partOrdersToUpdate = new List<Part_Order__c>();
				// set Status to 'Delivered'
				for (Part_Order__c ord : partOrders) {
					ord.Status__c = 'Delivered';
					partOrdersToUpdate.add(ord);
				}

				update partOrdersToUpdate;
			}
		}
	}
}