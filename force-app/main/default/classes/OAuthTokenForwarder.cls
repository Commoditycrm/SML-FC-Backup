public with sharing class OAuthTokenForwarder {

    // ------------ RESPONSE WRAPPERS ------------
    public class SalesforceTokenResponse {
        public String access_token;
        public String instance_url;
        public String token_type;
        public String id;
        public String issued_at;
        public String signature;
    }

    public class ExternalPostResponse {
        public Integer statusCode;
        public String body;
        public Map<String, String> headers = new Map<String, String>();
    }

    // ------------ PUBLIC ENTRYPOINT ------------
    public static ExternalPostResponse run(String configDeveloperName) {
        OAuth_Token_Forwarder_Config__mdt cfg = loadConfig(configDeveloperName);
        validateConfig(cfg);

        SalesforceTokenResponse token = fetchSalesforceOAuthToken(cfg);

        return postTokenToExternal(cfg, token);
    }

    // ------------ CONFIG LOAD ------------
    private static OAuth_Token_Forwarder_Config__mdt loadConfig(String devName) {

        OAuth_Token_Forwarder_Config__mdt cfg = [
            SELECT DeveloperName,
                   SF_Token_Url__c,
                   Client_Id__c,
                   Client_Secret__c,
                   Username__c,
                   Password__c,
                   External_Endpoint__c,
                   Timeout_Ms__c, API_Key__c 
            FROM OAuth_Token_Forwarder_Config__mdt
            WHERE DeveloperName = :devName
            LIMIT 1
        ];
        return cfg;
    }

    // ------------ 1) GET SF OAUTH TOKEN ------------
    private static SalesforceTokenResponse fetchSalesforceOAuthToken(OAuth_Token_Forwarder_Config__mdt cfg) {
        String endPoint = cfg.SF_Token_Url__c + '?grant_type=password&client_id=' + cfg.Client_Id__c + '&client_secret='
            + cfg.Client_Secret__c + '&username=' + cfg.Username__c + '&password=' + cfg.Password__c;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setTimeout(getTimeout(cfg));
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        Http http = new Http();
        HttpResponse res;
            res = http.send(req);
            SalesforceTokenResponse sfRes = (SalesforceTokenResponse) JSON.deserialize(res.getBody(), SalesforceTokenResponse.class);
            system.debug('OAuthTokenForwarder.fetchSalesforceOAuthToken - Deserialized Token: ' + sfRes);
            return sfRes;
    }

    // ------------ 2) POST TOKEN TO EXTERNAL SERVER ------------
    private static ExternalPostResponse postTokenToExternal(
        OAuth_Token_Forwarder_Config__mdt cfg,
        SalesforceTokenResponse token
    ) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(cfg.External_Endpoint__c);
        req.setMethod('POST');
        req.setTimeout(getTimeout(cfg));
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', cfg.API_Key__c);

        Map<String, Object> payload = new Map<String, Object>{
            'token' => token.access_token,
            'url' => token.instance_url + '/services/apexrest/ProcessM2MDEvents',
            'authType' => token.token_type
        };

        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (Exception e) {
            throw new AuraHandledException('External callout failed: ' + e.getMessage());
        }

        ExternalPostResponse out = new ExternalPostResponse();
        out.statusCode = (res == null) ? 0 : res.getStatusCode();
        out.body = (res == null) ? null : res.getBody();

        if (res != null) {
            for (String h : new List<String>{'Date','Content-Type','Server'}) {
                String v = res.getHeader(h);
                if (v != null) out.headers.put(h, v);
            }
        }

        if (res == null || res.getStatusCode() < 200 || res.getStatusCode() > 299) {
            throw new AuraHandledException(
                'External post failed. Status=' + out.statusCode + ', Body=' + safeBody(out.body)
            );
        }

        return out;
    }

    // ------------ HELPERS ------------
    private static void validateConfig(OAuth_Token_Forwarder_Config__mdt cfg) {
        List<String> missing = new List<String>();

        if (String.isBlank(cfg.SF_Token_Url__c)) missing.add('SF_Token_Url__c');
        if (String.isBlank(cfg.Client_Id__c)) missing.add('Client_Id__c');
        if (String.isBlank(cfg.Client_Secret__c)) missing.add('Client_Secret__c');
        if (String.isBlank(cfg.Username__c)) missing.add('Username__c');
        if (String.isBlank(cfg.Password__c)) missing.add('Password__c');
        if (String.isBlank(cfg.External_Endpoint__c)) missing.add('External_Endpoint__c');

        if (!missing.isEmpty()) {
            throw new AuraHandledException('Missing metadata fields: ' + String.join(missing, ', '));
        }
    }

    private static Integer getTimeout(OAuth_Token_Forwarder_Config__mdt cfg) {
        Integer t = (cfg.Timeout_Ms__c == null) ? 20000 : Integer.valueOf(cfg.Timeout_Ms__c);
        // keep it sane
        if (t < 1000) t = 1000;
        if (t > 120000) t = 120000;
        return t;
    }

    private static String safeBody(String body) {
        if (body == null) return null;
        Integer maxLen = 2000;
        return body.length() > maxLen ? body.substring(0, maxLen) + '...<truncated>' : body;
    }
}