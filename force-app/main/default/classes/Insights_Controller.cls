public with sharing class Insights_Controller {
    @AuraEnabled
    public static String generateInsights(String prompt, String accountId) {
       if (String.isBlank(prompt)) {
            throw new AuraHandledException('Prompt is required.');
        }

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        req.setEndpoint('https://unmodelled-marquis-nonexpulsive.ngrok-free.dev/query');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> payload = new Map<String, Object>{
            'query' => prompt, 'include_metadata' => true, 'account_id' => accountId
        };
        req.setBody(JSON.serialize(payload));

        HttpResponse res = http.send(req);

        Integer code = res.getStatusCode();
        if (code >= 200 && code < 300) {
             Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return JSON.serialize(res.getBody());
            //return 'Success'; //res.getBody();
        } else {
            String msg = 'External call failed: ' + code + ' - ' + res.getStatus();
            if (String.isNotBlank(res.getBody())) {
                msg += ' | ' + res.getBody();
            }
            throw new AuraHandledException(msg);
        }
    }
}