global with sharing class Chorus_Controller implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {

    private static Map<String, Id> modelCache = new Map<String, Id>();
    private static Id testingAccountId;

    private Boolean shouldSchedule = false;
    private Boolean calloutSuccess = false;
    private Boolean hasData = false;
    private Datetime processingTimeToSet;

    global Iterable<String> start(Database.BatchableContext bc) {
        List<String> serializedDataPoints = new List<String>();

        try {
            Api_Config__c cfg = Api_Config__c.getOrgDefaults();

            Datetime nowUtc = Datetime.now();
            Datetime oneHourAgoUtc = cfg.Chorus_minServerProcessingTime__c;
            processingTimeToSet = nowUtc;

            List<String> chorusDeviceIds = null;//new List<String>{'17485023f678', '78df0a919a4e', 'ec4d3dc5b730', '058c915df12f', '9834af3cc6f9', '21154d73295b', '8f3f4e803479', 'bfdf024c9b6c', '2e38686b3bbd', '57ec4dbdc6e5'};
            String nextPageToken;
            Integer calloutCount = 0;
            Integer maxCallouts = 10;//0;

            do {
                String bodyJson = buildBodyJson(
                    oneHourAgoUtc,
                    chorusDeviceIds,
                    nextPageToken
                );

                String freshJwt = UtilityClass.generateRS256JWT();

                HttpResponse res = doCallout(cfg.Endpoint__c, freshJwt, bodyJson);
                calloutCount++;

                if (res == null || res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
                    shouldSchedule = true;
                    return serializedDataPoints;
                }

                String body = res.getBody();

                if (String.isBlank(body)) {
                    shouldSchedule = true;
                    return serializedDataPoints;
                }

                if (isCpuNearLimit()) {
                    /*cfg.Chorus_minServerProcessingTime__c = processingTimeToSet;
                    update cfg;*/

                    //scheduleJob();

                    shouldSchedule = false;
                    calloutSuccess = true;
                    String email = System.label.Email_address;
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setToAddresses(new String[] {email, 'kacey@smartlogisticsinc.com'});
                    String subject = 'Chorus Controller CPU Limit Reached';
                    msg.setSubject(subject);

                    String msgBody = 'User/Org details: ' + UserInfo.getUserId() + '/' + UserInfo.getOrganizationId() + '\n\n' 
                                + Datetime.now() + '\n\n'
                                + 'Message: Reached CPU Limit to 85%' + '\n\n';
                    msg.setPlainTextBody(msgBody);

                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
                    if (!serializedDataPoints.isEmpty()) {
                        hasData = true;
                    } else {
                        shouldSchedule = true;
                    }

                    return serializedDataPoints;
                }
                Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(body);

                List<Object> pageDataPoints = (List<Object>) root.get('dataPoints');

                if (pageDataPoints != null && !pageDataPoints.isEmpty()) {
                    for (Object raw : pageDataPoints) {
                        serializedDataPoints.add(JSON.serialize(raw));
                    }
                }

                nextPageToken = (String) root.get('nextPageToken');

            } while (!String.isBlank(nextPageToken) && calloutCount < maxCallouts);

            calloutSuccess = true;

            if (!serializedDataPoints.isEmpty()) {
                hasData = true;
            } else {
                shouldSchedule = true;
            }

            return serializedDataPoints;

        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e,'Chorus_Controller','start','Exception',null,null,true);
            shouldSchedule = true;
            return serializedDataPoints;
        }
    }

    global void execute(Database.BatchableContext bc, List<String> scope) {
        try {
            if (scope == null || scope.isEmpty()) {
                return;
            }

            List<Object> dataPoints = new List<Object>();

            for (String rawJson : scope) {
                if (!String.isBlank(rawJson)) {
                    dataPoints.add(JSON.deserializeUntyped(rawJson));
                }
            }

            if (dataPoints.isEmpty()) {
                return;
            }

            Set<String> deviceIds = new Set<String>();
            Map<String, String> deviceTypeByDeviceId = new Map<String, String>();

            for (Object raw : dataPoints) {
                Map<String, Object> dp = (Map<String, Object>) raw;

                String deviceId = (String) dp.get('deviceId');
                String deviceType = (String) dp.get('deviceType');

                if (!String.isBlank(deviceId)) {
                    deviceIds.add(deviceId);
                    deviceTypeByDeviceId.put(deviceId, deviceType);
                }
            }

            Map<String, Asset> assetsByDeviceId = getOrCreateAssets(
                deviceIds,
                deviceTypeByDeviceId
            );

            List<Api_Response__c> parents = new List<Api_Response__c>();

            for (Object raw : dataPoints) {
                Map<String, Object> dp = (Map<String, Object>) raw;

                String deviceId = (String) dp.get('deviceId');
                String recordTimeIso = (String) dp.get('recordTime');

                Map<String, Object> agg = (Map<String, Object>) dp.get('aggregatorDetails');
                Map<String, Object> temp = (Map<String, Object>) dp.get('temperature');
                Map<String, Object> loc = (Map<String, Object>) dp.get('ownLocation');

                Asset ast = assetsByDeviceId.get(deviceId);

                if (ast == null) {
                    continue;
                }

                Api_Response__c parent = new Api_Response__c();
                parent.Asset__c              = ast.Id;
                parent.Status__c             = 'Chorus-New';
                parent.Device_Id__c          = deviceId;
                parent.Location_TimeStamp__c = recordTimeIso;
                parent.ResEnteringDttime__c  = System.now();
                parent.Incoming_Messsage__c  = JSON.serialize(dp);
                parent.Device_Status__c      = agg  != null ? JSON.serialize(agg)  : null;
                parent.Temp__c               = temp != null ? JSON.serialize(temp) : null;
                parent.Loc__c                = loc  != null ? JSON.serialize(loc)  : null;

                parents.add(parent);
            }

            if (!parents.isEmpty()) {
                insert parents;
            }

        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e,'Chorus_Controller','execute','Exception',null,null,true);
            shouldSchedule = true;
        }
    }

    global void finish(Database.BatchableContext bc) {
        try {
            if (shouldSchedule || !calloutSuccess || !hasData) {
                scheduleJob();
                return;
            }

            Database.executeBatch(new Chorus_ArcBatch(), 10);

            Api_Config__c cfg = Api_Config__c.getOrgDefaults();

            if (processingTimeToSet != null) {
                cfg.Chorus_minServerProcessingTime__c = processingTimeToSet;
                update cfg;
            }

        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e,'Chorus_Controller','finish','Exception',null,null,true);
            scheduleJob();
        }
    }

    // =================== HELPERS ===================

    private static HttpResponse doCallout(String endpoint, String jwt, String bodyJson) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setEndpoint(endpoint);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + jwt);
        req.setBody(bodyJson);

        Http http = new Http();

        try {
            return http.send(req);
        } catch (Exception e) {
            RedesignNL_CaptureErrors.createErrorLogs(e,'Chorus_Controller','doCallout','Callout failed',null,null,true);
            return null;
        }
    }

    private static String buildBodyJson(
        Datetime minServerProcessingTimeUtc,
        List<String> deviceIds,
        String nextPageToken
    ) {
        Map<String, Object> m = new Map<String, Object>{
            'minServerProcessingTime' => minServerProcessingTimeUtc,
            'deviceIds' => deviceIds == null ? new List<String>() : deviceIds
        };

        if (!String.isBlank(nextPageToken)) {
            m.put('pageToken', nextPageToken);
        }

        return JSON.serialize(m);
    }

    private static Map<String, Asset> getOrCreateAssets(
        Set<String> deviceIds,
        Map<String, String> deviceTypeByDeviceId
    ) {
        Map<String, Asset> result = new Map<String, Asset>();

        if (deviceIds == null || deviceIds.isEmpty()) {
            return result;
        }

        for (Asset a : [
            SELECT Id, Name, Device_Id__c, Is_Chorus_Asset__c, Product2Id
            FROM Asset
            WHERE Device_Id__c IN :deviceIds
        ]) {
            result.put(a.Device_Id__c, a);
        }

        Id accId = getTestingAccountId();

        List<Asset> toInsert = new List<Asset>();
        List<Asset> toUpdate = new List<Asset>();

        for (String devId : deviceIds) {
            if (String.isBlank(devId)) {
                continue;
            }

            Asset existing = result.get(devId);

            if (existing != null) {
                if (!existing.Is_Chorus_Asset__c) {
                    existing.Is_Chorus_Asset__c = true;
                    toUpdate.add(existing);
                }

                continue;
            }

            String devType = deviceTypeByDeviceId.get(devId);

            Asset ast = new Asset();
            ast.AccountId             = accId;
            ast.AssetProvidedById     = accId;
            ast.Device_Id__c          = devId;
            ast.Name                  = devId;
            ast.Product2Id            = getModel(devType);
            ast.Is_Loco_Asset__c      = false;
            ast.Is_Nimbelink_Asset__c = false;
            ast.Is_Chorus_Asset__c    = true;

            toInsert.add(ast);
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;

            for (Asset a : toInsert) {
                result.put(a.Device_Id__c, a);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }

        return result;
    }

    private static Id getTestingAccountId() {
        if (testingAccountId != null) {
            return testingAccountId;
        }

        List<Account> accList = [
            SELECT Id
            FROM Account
            WHERE Name = 'Testing'
            LIMIT 1
        ];

        testingAccountId = accList.isEmpty() ? null : accList[0].Id;

        return testingAccountId;
    }

    public static void scheduleJob() {
        Datetime nextRun = System.now().addMinutes(5);

        String cron = String.format(
            '{0} {1} {2} {3} {4} ? {5}',
            new List<Object>{
                nextRun.second(),
                nextRun.minute(),
                nextRun.hour(),
                nextRun.day(),
                nextRun.month(),
                nextRun.year()
            }
        );

        String jobName = 'Chorus_Chained_' + String.valueOf(nextRun.getTime());

        System.schedule(jobName, cron, new Chorus_Scheduler());
    }

    private static Id getModel(String model) {
        if (String.isBlank(model)) {
            model = 'UNKNOWN';
        }

        if (modelCache.containsKey(model)) {
            return modelCache.get(model);
        }

        List<Product2> modelID = [
            SELECT Id, Name
            FROM Product2
            WHERE Name = :model
            LIMIT 1
        ];

        if (!modelID.isEmpty()) {
            modelCache.put(model, modelID[0].Id);
            return modelID[0].Id;
        }

        Product2 prod = new Product2();
        prod.Name = model;
        prod.IsActive = true;

        insert prod;

        modelCache.put(model, prod.Id);

        return prod.Id;
    }
    private static Boolean isCpuNearLimit() {
        Integer usedCpu = Limits.getCpuTime();
        Integer maxCpu = Limits.getLimitCpuTime();

        // Stop when 75% CPU is used
        return usedCpu >= Math.floor(maxCpu * 0.80);
    }
}