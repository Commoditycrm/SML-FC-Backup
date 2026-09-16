/**
* @File Name : LocoAware_AssetDeactivation_ctrl.cls
* @Description : this class is being used to deactivate locoAware Assets from Lwc
* @Author :Govardhan Reddy
* @Last Modified By :Govardhan Reddy
* @Last Modified On : May 9, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 9, 2025 |   | Initial Version
**/

public class LocoAware_AssetDeactivation_ctrl {
	@AuraEnabled
	public static string deactivateAsset(List<String> AstList){
		string msg;
        Map<String, Object> requestPayload = new Map<String, Object>();
        requestPayload.put('dryRun', false);
        requestPayload.put('comment', 'Asset Deactivation');

        Map<String, Object> deviceMap = new Map<String, Object>();
        deviceMap.put('devices', AstList);
        requestPayload.put('where', deviceMap);

        String body = JSON.serialize(requestPayload);

		String token = System.Label.LocoAware_Asset_Deactivation_ApiToken;
		String authorizationToken = 'Bearer'+' '+ token;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://locoaware.com/api/bulk/deactivate'); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationToken); 
        req.setBody(body);

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Response status: ' + res.getStatus());
            System.debug('Response body: ' + res.getBody());
			if(res.getStatusCode() == 200){
				Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
				/*if(result.get('hasError')==false){
                	msg = 'Your Request has been Processed Successfully !';
				}else{*/
					List<String> devResList = new List<String>();
					Map<String, Object> summary = (Map<String, Object>) result.get('summary');
					List<object> successDevices = (List<Object>) summary.get('successes');
					for(object sucObj : successDevices){
						Map<String, Object> sucMap = (Map<String, Object>) sucObj;
						List<Object> sucdevices = (List<Object>) sucMap.get('devices');
						String sucdevMsg;
						if(sucdevices.size()<=10 && sucdevices.size()>0){
							sucdevMsg = String.join(sucdevices, ', ');
							sucdevMsg = 'Your Request has been Processed Successfully for following Assets :'+sucdevMsg;
								devResList.add(sucdevMsg);
						}else if(sucdevices.size()>10){
							sucdevMsg = sucdevices.size() + ' have been deactivated successfully.';
						}
					}
					List<Object> errors = (List<Object>) summary.get('errors');
					for (Object errObj : errors) {
						Map<String, Object> errMap = (Map<String, Object>) errObj;
						List<Object> devices = (List<Object>) errMap.get('devices');
						String message = (String) errMap.get('message');
						if(devices.size()>0){
							devResList.add('Errors have been found for following Assets.');
							for (Object deviceId : devices) {
								devResList.add('    Device - ' + String.valueOf(deviceId) + ': ' + message);
							}
						}
					}
					msg = String.join(devResList, '<br/>');
				//}
            }else{
                msg = 'Error  Statuscode: '+ res.getStatusCode() +'\n\n Response Body: \n' +res.getBody(); 
            }
        } catch (Exception e) {
            msg = 'Callout error: ' + e.getMessage();
        }
		return msg;

	}
}