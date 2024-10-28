/**
 * @author RadialSpark
 * @date 05-10-2018
 * @description Generates mock http response for testing UpdateBackhaulBolsBatch.cls
 * @changelog
	05-10-2018 - Bradley Wong - Created
    06-14-2018 - Bradley Wong - added query for BOL_NAME to find BOL__c.Name
 */

@isTest
global class HttpMockResponse_UpdateBackhaulBolsBatch implements HttpCalloutMock {
    public static Boolean bypassBolQuery = false;

    private Integer statusCode;

    private static final String bolNum = [SELECT Name FROM BOL__c LIMIT 1].Name;

	//Sample Xml String with two Load objects
    private static final String USERNAME = 'tmsUsername';
	private static final String PASSWORD = 'tmsPassword';
	private static final String LOAD_NUM = '3gTmsBolNum';
	private static final String TMS_ENDPOINT = 'https://www.testTmsEndpoint.com/callWebService?webServiceName=SmartPalletLoadGet'
		+ '&username='
		+ USERNAME
		+ '&password='
		+ PASSWORD
        + '&xmlPayload=%3CloadNum%3E' + bolNum + '%3C%2FloadNum%3E';


    private static final String BOL_NAME = bypassBolQuery == true ? '' : [SELECT Name FROM BOL__c LIMIT 1][0].Name;

	// private static final String sampleXmlLoadResponse = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><ns2:LoadData xmlns:ns2="http://schemas.3gtms.com/tms/v1/tns"><BatchInfo><BatchDateTime>2018-05-02T19:01:20.322Z</BatchDateTime><SentBy>SP-INT</SentBy><PageNum>1</PageNum><PageCnt>1</PageCnt></BatchInfo><Loads><Load><EntityHeader><DateCreated>2018-05-01T16:43:00Z</DateCreated><CreatedBy>SP-INT</CreatedBy><DateLastModified>2018-05-01T16:43:00Z</DateLastModified><LastModifiedBy>SP-INT</LastModifiedBy></EntityHeader><BOLNum>3gTmsBolNum</BOLNum><PlannedStart>2018-01-02T15:20:00Z</PlannedStart><PlannedEnd>2018-01-03T16:41:00Z</PlannedEnd><OrderNums><OrderNum>P001-O171228-00001-TEST</OrderNum></OrderNums><TransportMode>TL</TransportMode><TotalPieceCount>323</TotalPieceCount></Load></Loads></ns2:LoadData>';
    private static final String sampleXmlLoadResponse =
        '<ns2:LoadData xmlns:ns2="http://schemas.3gtms.com/tms/v1/tns"> <BatchInfo> <BatchDateTime>2018-06-14T23:12:45.338Z</BatchDateTime> <SentBy>SP-INT</SentBy> <PageNum>1</PageNum> <PageCnt>1</PageCnt> </BatchInfo> <Loads> <Load> <EntityHeader> <DateCreated>2018-06-12T22:40:00Z</DateCreated> <CreatedBy>SP-INT</CreatedBy> <DateLastModified>2018-06-12T22:41:00Z</DateLastModified> <LastModifiedBy>HUBTRANS</LastModifiedBy> </EntityHeader> <OrganizationName>Smart_Pallets</OrganizationName> <LoadNum>' +
        BOL_NAME +
        '</LoadNum> <PlannedStart>2018-02-02T12:00:00Z</PlannedStart> <PlannedEnd>2018-02-02T12:00:00Z</PlannedEnd> <TotalGrossWeight> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </TotalGrossWeight> <TotalNetWeight> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </TotalNetWeight> <TotalGrossVolume> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalGrossVolume> <TotalNetVolume> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalNetVolume> <TotalPieceCount>20</TotalPieceCount> <TotalHandlingUnitCount>20</TotalHandlingUnitCount> <LoadTMSStatus>Planned</LoadTMSStatus> <AreConstraintsOverridden>false</AreConstraintsOverridden> <TotalNetOrdCharge> <CurrencyValue uom="USD">0.00</CurrencyValue> <CurrencyBase uom="USD">0.00</CurrencyBase> </TotalNetOrdCharge> <NetProfit> <CurrencyValue uom="USD">0.00</CurrencyValue> <CurrencyBase uom="USD">0.00</CurrencyBase> </NetProfit> <NetMargin>0.00</NetMargin> <FreightBillStatus>NoFreightBill</FreightBillStatus> <TotalThirdPartyCharge> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </TotalThirdPartyCharge> <IntegrationStatus>Sent</IntegrationStatus> <Transmitted>2018-06-12T22:41:00Z</Transmitted> <Flex1Total>0.000000</Flex1Total> <IsRoundTrip>false</IsRoundTrip> <RouteNum>R180612-00329</RouteNum> <RateSource>NoRate</RateSource> <IsTrunk>true</IsTrunk> <CreatedFromMultiStopOrd>false</CreatedFromMultiStopOrd> <IsSharedSavingIneligible>false</IsSharedSavingIneligible> <IsSharedSavingsRebateDeducted>false</IsSharedSavingsRebateDeducted> <BroadcastOffers/> <LoadSource>Integration</LoadSource> <InvoiceStatusLoadBilling>NoInvoice</InvoiceStatusLoadBilling> <BrokerageLock>false</BrokerageLock> <OrderNums> <OrderNum>B-0334-Order</OrderNum> </OrderNums> <LoadComments/> <LoadRefNums/> <LoadCosts/> <LoadCostBenchmarks/> <LoadHandlingUnits> <LoadHandlingUnit> <HandlingUnit> <HandlingUnitNum>B-0334-HandlingUnit</HandlingUnitNum> <TotalWeightGrossPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </TotalWeightGrossPlanned> <TotalWeightNetPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </TotalWeightNetPlanned> <TotalVolumeGrossPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalVolumeGrossPlanned> <TotalVolumeNetPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalVolumeNetPlanned> <TotalPieceCountPlanned>20</TotalPieceCountPlanned> <TotalHandlingUnitCountPlanned>20</TotalHandlingUnitCountPlanned> <Flex1TotalPlanned>0.000000</Flex1TotalPlanned> <Flex2TotalPlanned>0.000000</Flex2TotalPlanned> <HandlingUnitLines> <HandlingUnitLine> <OrdNum>B-0334-Order</OrdNum> <OrdLineNum>1</OrdLineNum> <WeightGrossPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </WeightGrossPlanned> <WeightNetPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </WeightNetPlanned> <VolumeGrossPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </VolumeGrossPlanned> <VolumeNetPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </VolumeNetPlanned> <PieceCountPlanned>20</PieceCountPlanned> <HandlingUnitCountPlanned>20</HandlingUnitCountPlanned> <Flex1Planned>0.000000</Flex1Planned> <Flex2Planned>0.000000</Flex2Planned> </HandlingUnitLine> <HandlingUnitLine> <OrdNum>B-0334-Order</OrdNum> <OrdLineNum>2</OrdLineNum> <WeightGrossPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </WeightGrossPlanned> <WeightNetPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </WeightNetPlanned> <VolumeGrossPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </VolumeGrossPlanned> <VolumeNetPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </VolumeNetPlanned> <PieceCountPlanned>0</PieceCountPlanned> <HandlingUnitCountPlanned>0</HandlingUnitCountPlanned> <Flex1Planned>0.000000</Flex1Planned> <Flex2Planned>0.000000</Flex2Planned> </HandlingUnitLine> </HandlingUnitLines> </HandlingUnit> <StopNumPickup>1</StopNumPickup> <StopNumDelivery>2</StopNumDelivery> </LoadHandlingUnit> </LoadHandlingUnits> <Stops> <Stop> <StopNum>1</StopNum> <StopType>Pickup</StopType> <PlannedArrival>2018-02-02T12:00:00Z</PlannedArrival> <TotalWeightGrossPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </TotalWeightGrossPlanned> <TotalWeightNetPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </TotalWeightNetPlanned> <TotalVolumeGrossPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalVolumeGrossPlanned> <TotalVolumeNetPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalVolumeNetPlanned> <TotalPieceCountPlanned>20</TotalPieceCountPlanned> <TotalHandlingUnitCountPlanned>20</TotalHandlingUnitCountPlanned> <WasDetained>false</WasDetained> <Flex1TotalPlanned>0.000000</Flex1TotalPlanned> <Flex2TotalPlanned>0.000000</Flex2TotalPlanned> <IsAppointmentRequired>false</IsAppointmentRequired> <IsAppointmentRequested>false</IsAppointmentRequested> <HasAppointmentWindow>false</HasAppointmentWindow> <IsAppointmentMade>false</IsAppointmentMade> <LocNum>B-0334-Pickup_Location</LocNum> <OrderNums> <OrderNum>B-0334-Order</OrderNum> </OrderNums> <StopComments/> <StopRefNums/> </Stop> <Stop> <StopNum>2</StopNum> <StopType>Delivery</StopType> <PlannedArrival>2018-02-02T12:00:00Z</PlannedArrival> <TotalWeightGrossPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </TotalWeightGrossPlanned> <TotalWeightNetPlanned> <WeightValue uom="Lb">0.000000</WeightValue> <WeightBase uom="Lb">0.000000</WeightBase> </TotalWeightNetPlanned> <TotalVolumeGrossPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalVolumeGrossPlanned> <TotalVolumeNetPlanned> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalVolumeNetPlanned> <TotalPieceCountPlanned>20</TotalPieceCountPlanned> <TotalHandlingUnitCountPlanned>20</TotalHandlingUnitCountPlanned> <WasDetained>false</WasDetained> <Flex1TotalPlanned>0.000000</Flex1TotalPlanned> <Flex2TotalPlanned>0.000000</Flex2TotalPlanned> <IsAppointmentRequired>false</IsAppointmentRequired> <IsAppointmentRequested>false</IsAppointmentRequested> <HasAppointmentWindow>false</HasAppointmentWindow> <IsAppointmentMade>false</IsAppointmentMade> <LocNum>B-0334-Delivery_Location</LocNum> <OrderNums> <OrderNum>B-0334-Order</OrderNum> </OrderNums> <StopComments/> <StopRefNums/> </Stop> </Stops> <LoadRelatedPartys/> <LoadAdvances/> </Load> </Loads> </ns2:LoadData>';

    public HttpMockResponse_UpdateBackhaulBolsBatch(Integer statusCode) {
        this.statusCode = statusCode;
    }

	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals(TMS_ENDPOINT, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(sampleXmlLoadResponse);
        res.setStatusCode(this.statusCode);
        return res;
    }
}