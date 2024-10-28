/**
 * @author Connor Zint
 * @date 2/26/2018
 * @description Handler class for OrderTrigger
 */
public without sharing class OrderTriggerHandler extends TriggerHandler {

	private List<Order__c> triggerNew;

    /**
     * @description Standard constructor -- sets class variables
     * @param records wrapped trigger context data structures
     */
    public OrderTriggerHandler(TriggerRecordWrapper records) {
        super(records);
		triggerNew = (List<Order__c>)records.getTriggerNew();
    }

    public override void doAfterInsert() {
		
		// call service methods
		//service_method();
	} 

	/**
	 * 
	 */ 
	 private HttpResponse httpCallout(String url, String httpMethod, String requestBody) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(url);
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		request.setMethod(httpMethod);

		if (httpMethod == 'POST' || httpMethod == 'PUT') {
			request.setBody(requestBody);
		}

		HttpResponse response = http.send(request);
		return response;
	 }


	/**
     * @description 
     */
	@TestVisible
	private HttpResponse createOrder_3gTms() {

		//send request to TMS Dynamic Logistix to create order
		String username = 'testUsername';
		String password = 'testPassword';
		String ordersUrl = 'http://3gtms.host/integration/rest/orders?username=' + username+ '&password=' + password;

		List<Map<String, String>> ordersRequestBody = new List<Map<String, String>>();
		for (Order__c o : triggerNew) {
			Map<String, String> orderMap = new Map<String, String>{
				'Source_Location' => String.valueOf(o.Source_Location__c),
				'Target_Location' => String.valueOf(o.Target_Location__c),
				'Dropoff' => String.valueOf(o.Dropoff__c),
				'Pickup' => String.valueOf(o.Pickup__c),
				'Number_of_Pallets' => String.valueOf(o.Number_of_Pallets__c)
			};

			ordersRequestBody.add(orderMap);
		}

		String serializedOrdersBody = JSON.serialize(ordersRequestBody);
		HttpResponse tmsOrdersResponse = httpCallout(ordersUrl, 'POST', serializedOrdersBody);

		if (tmsOrdersResponse.getStatusCode() == 200) {
			//get load Id from tms response (need to change property name)
			Object tmsOrdersResponseData = tmsOrdersResponse.getBody();

			//send request to TMS loads endpoint to get load information for BOL__c
			String loadId = '';
			String details = '';
 			String loadsUrl = 'http://3gtms.host/integration/rest/loads/' + loadId + '?includeDocs=true&detailed=' + details + '&username=' + username + '&password=' + password;
			Map<String, String> loadsRequest = new Map<String, String>();
			String serializedLoadsBody = JSON.serialize(loadsRequest);

			HttpResponse tmsLoadsResponse = httpCallout(loadsUrl, 'GET', serializedLoadsBody);
			
			if (tmsLoadsResponse.getStatusCode() == 200) {
				//on successful TMS order creation ==> create new BOL__c object with response data
				//set bol properties here with data from loadResponse and ordersResponse
				BOL__c bol = new BOL__c();
                
                //added for testing purposes
                return tmsLoadsResponse;
			}



		} else {
			//other error response code handling
			System.debug('There has been an error ' + tmsOrdersResponse.getStatus());
		}

        //added for testing purposes
		return null;

	}

}