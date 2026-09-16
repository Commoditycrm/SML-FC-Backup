/**
 * @author RadialSpark
 * @date 05-24-2018
 * @description Utility class for storing constant values
 * @changelog
	05-24-2018 - Bradley Wong - Created
	06-01-2018 - Bradley Wong - added Order fields
	06-05-2018 - Bradley Wong - refactored to allow creation of Orders within LoadData
	06-11-2018 - Bradley Wong - added TradingPartner fields
 */

public class ConstantsUtility {
	public static final String TEST_BOL_RESPONSE = '<Orders> <Order> <TotalGrossWeight> <WeightValue uom="Lb">22500.000000</WeightValue> <WeightBase uom="Lb">22500.000000</WeightBase> </TotalGrossWeight> <TotalNetWeight> <WeightValue uom="Lb">22500.000000</WeightValue> <WeightBase uom="Lb">22500.000000</WeightBase> </TotalNetWeight> <TotalGrossVolume> <VolumeValue uom="CuFt">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </TotalGrossVolume> <Currency>USD</Currency> <TotalNetFreightCharge> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </TotalNetFreightCharge> <TotalNetAccessorialCharge> <CurrencyValue uom="USD">0.00</CurrencyValue> <CurrencyBase uom="USD">0.000000</CurrencyBase> </TotalNetAccessorialCharge> <TotalNetCharge> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </TotalNetCharge> <IsHot>false</IsHot> <IsExemptAppointmentCalendar>false</IsExemptAppointmentCalendar> <IsHazmat>false</IsHazmat> <BillingStatus>Billed</BillingStatus> <InvoiceStatusOriginal>Billed</InvoiceStatusOriginal> <DoNotInvoice>false</DoNotInvoice> <IsGainshareIneligible>false</IsGainshareIneligible> <TotalBenchmark> <CurrencyValue uom="USD">0.00</CurrencyValue> <CurrencyBase uom="USD">0.000000</CurrencyBase> </TotalBenchmark> <TotalThirdPartyCharge> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </TotalThirdPartyCharge> <TotalBenchmarkAllocated> <CurrencyValue uom="USD">0.00</CurrencyValue> <CurrencyBase uom="USD">0.000000</CurrencyBase> </TotalBenchmarkAllocated> <IsAppointmentRequestedPickup>false</IsAppointmentRequestedPickup> <IsAppointmentRequestedDelivery>false</IsAppointmentRequestedDelivery> <IsSharedSavingsRebateDeducted>false</IsSharedSavingsRebateDeducted> <BrokerageLock>false</BrokerageLock> <IsAppointmentMadePickup>false</IsAppointmentMadePickup> <IsAppointmentMadeDelivery>false</IsAppointmentMadeDelivery> <OrdLegCount>1</OrdLegCount> <IsExemptOrdLegTemplate>false</IsExemptOrdLegTemplate> <OriginLocNum>LOC-00001895</OriginLocNum> <DestinationLocNum>LOC-00001896</DestinationLocNum> <BillToLocNum>LOC-00001705</BillToLocNum> <Client> <EntityHeader> <DateCreated>2018-05-07T21:09:00Z</DateCreated> <CreatedBy>Smart_JobUser</CreatedBy> <DateLastModified>2018-05-07T21:14:00Z</DateLastModified> <LastModifiedBy>Smart_JobUser</LastModifiedBy> </EntityHeader> <OrganizationName>Smart_Pallets</OrganizationName> <TradingPartnerName>Smart Logistics</TradingPartnerName> <TradingPartnerNum>Smart Logistics</TradingPartnerNum> <TradingPartnerType>Client</TradingPartnerType> <IsActive>true</IsActive> <FreightTerms xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> <FederalId xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> <DunsId xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> <DunsRating xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> <Gs1Prefix xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> <CrossdockPoolConstraint xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> <DoNotAllowMultistop>false</DoNotAllowMultistop> <IncludeNonClientSpecificCommodities>true</IncludeNonClientSpecificCommodities> <Currency>USD</Currency> <TradingPartnerDetail> <TradingPartnerClient> <SendProFormaBilling>false</SendProFormaBilling> <IsOnCreditHold>false</IsOnCreditHold> <IgnoreCreditLimit>true</IgnoreCreditLimit> <CreditOverPercent>0.00</CreditOverPercent> <CreditLimit> <CurrencyValue uom="USD">0.000000</CurrencyValue> <CurrencyBase uom="USD">0.000000</CurrencyBase> </CreditLimit> <OverAllowance> <CurrencyValue uom="USD">0.000000</CurrencyValue> <CurrencyBase uom="USD">0.000000</CurrencyBase> </OverAllowance> <CreditAvailable> <CurrencyValue uom="USD">0.000000</CurrencyValue> <CurrencyBase uom="USD">0.000000</CurrencyBase> </CreditAvailable> <LastPayment> <CurrencyValue uom="USD">0.000000</CurrencyValue> <CurrencyBase uom="USD">0.000000</CurrencyBase> </LastPayment> <IncludeInvoiceDetail>true</IncludeInvoiceDetail> <BillingMethod>Manifest</BillingMethod> <ManifestFrequency>Daily</ManifestFrequency> <NegativeGainshareRule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> <RuleStatusBenchmarkRating>Disabled</RuleStatusBenchmarkRating> <RuleStatusGainshareBilling>Disabled</RuleStatusGainshareBilling> <ReceivesInvoiceMethodEmail>false</ReceivesInvoiceMethodEmail> <ReceivesInvoiceMethodIntegration>false</ReceivesInvoiceMethodIntegration> <ReceivesInvoiceMethodManual>true</ReceivesInvoiceMethodManual> <CurrencyOverrideInvoice xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> <ClientBillingDocs/> <ClientBillingRefNumRequireds/> <ClientInvoiceBatchDocConfigs> <ClientInvoiceBatchDocConfig> <MessageTypeName>Invoice</MessageTypeName> <InvoiceBatchOutputTemplateImplementationName>Manifest Invoice</InvoiceBatchOutputTemplateImplementationName> <ManifestType>ManifestHeader</ManifestType> </ClientInvoiceBatchDocConfig> <ClientInvoiceBatchDocConfig> <MessageTypeName>Invoice</MessageTypeName> <InvoiceBatchOutputTemplateImplementationName>FloPath Invoice</InvoiceBatchOutputTemplateImplementationName> <ManifestType>StandardInvoice</ManifestType> </ClientInvoiceBatchDocConfig> <ClientInvoiceBatchDocConfig> <MessageTypeName>Invoice</MessageTypeName> <InvoiceBatchOutputTemplateImplementationName>FloPath Invoice</InvoiceBatchOutputTemplateImplementationName> <ManifestType>ManifestChild</ManifestType> </ClientInvoiceBatchDocConfig> </ClientInvoiceBatchDocConfigs> <ClientInvoiceStatusDocGens> <ClientInvoiceStatusDocGen> <InvoiceStatus>Draft</InvoiceStatus> </ClientInvoiceStatusDocGen> <ClientInvoiceStatusDocGen> <InvoiceStatus>Billed</InvoiceStatus> </ClientInvoiceStatusDocGen> </ClientInvoiceStatusDocGens> <ClientInitialBillingStatuses> <ClientInitialBillingStatus> <LoadTMSStatus>Complete</LoadTMSStatus> </ClientInitialBillingStatus> <ClientInitialBillingStatus> <LoadTMSStatus>Canceled</LoadTMSStatus> </ClientInitialBillingStatus> <ClientInitialBillingStatus> <LoadTMSStatus>Closed</LoadTMSStatus> </ClientInitialBillingStatus> <ClientInitialBillingStatus> <LoadTMSStatus>Delivered</LoadTMSStatus> </ClientInitialBillingStatus> </ClientInitialBillingStatuses> <ClientBillingCompleteStatuses> <ClientBillingCompleteStatus> <LoadTMSStatus>Complete</LoadTMSStatus> </ClientBillingCompleteStatus> <ClientBillingCompleteStatus> <LoadTMSStatus>Canceled</LoadTMSStatus> </ClientBillingCompleteStatus> <ClientBillingCompleteStatus> <LoadTMSStatus>Closed</LoadTMSStatus> </ClientBillingCompleteStatus> <ClientBillingCompleteStatus> <LoadTMSStatus>Delivered</LoadTMSStatus> </ClientBillingCompleteStatus> </ClientBillingCompleteStatuses> </TradingPartnerClient> </TradingPartnerDetail> <TradingPartnerLocs/> <TradingPartnerComments/> <TradingPartnerRefNums/> <TradingPartnerRelatedPartys/> <TaxRegistrationNum xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"/> </Client> <OrderLines> <OrderLine> <OrdLineNum>1</OrdLineNum> <Description>SMART PALLETS</Description> <WeightGross> <WeightValue uom="Lb">22500.000000</WeightValue> <WeightBase uom="Lb">22500.000000</WeightBase> </WeightGross> <WeightNet> <WeightValue uom="Lb">22500.000000</WeightValue> <WeightBase uom="Lb">22500.000000</WeightBase> </WeightNet> <VolumeGross> <VolumeValue uom="CuIn">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </VolumeGross> <VolumeNet> <VolumeValue uom="CuIn">0.000000</VolumeValue> <VolumeBase uom="CuFt">0.000000</VolumeBase> </VolumeNet> <PieceCount>313</PieceCount> <HandlingUnitCount>313</HandlingUnitCount> <HandlingUnitLength> <DimensionValue uom="In">0.000000</DimensionValue> <DimensionBase uom="Ft">0.000000</DimensionBase> </HandlingUnitLength> <HandlingUnitWidth> <DimensionValue uom="In">0.000000</DimensionValue> <DimensionBase uom="Ft">0.000000</DimensionBase> </HandlingUnitWidth> <HandlingUnitHeight> <DimensionValue uom="In">0.000000</DimensionValue> <DimensionBase uom="Ft">0.000000</DimensionBase> </HandlingUnitHeight> <IsHazmat>false</IsHazmat> <IsFlaggedForDelete>false</IsFlaggedForDelete> <IsFreightClassLocked>false</IsFreightClassLocked> </OrderLine> </OrderLines> <OrderCharges> <OrdCharge> <CostType>Freight</CostType> <Charge> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </Charge> <DiscountPercent>0.00</DiscountPercent> <Discount> <CurrencyValue uom="USD">0.00</CurrencyValue> <CurrencyBase uom="USD">0.000000</CurrencyBase> </Discount> <TotalThirdPartyCharge> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </TotalThirdPartyCharge> <NetCharge> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </NetCharge> <NetChargeOperatingCurrency> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </NetChargeOperatingCurrency> <AccessorialQty>0.000000</AccessorialQty> <ThirdPartyCharge> <CurrencyValue uom="USD">1400.00</CurrencyValue> <CurrencyBase uom="USD">1400.000000</CurrencyBase> </ThirdPartyCharge> </OrdCharge> </OrderCharges> <OrderComments/> <OrderRefNums/> <OrderRelatedPartys/> <OrderServices/> <OrderCompatibilityProfiles/> <OrderStops/> </Order> </Orders>';
	//static variables that hold the count when more than one instance of the node is required in the XML body
	public static Integer locNum = 0;
	public static Integer stopNum = 0;
	public static Integer orderLineNum = 0;
	public static Integer handlingUnitNum = 0;

	public static Decimal SINGLE_PALLET_WEIGHT = 49.0;

	//variables used for parsing through XML responses
	public static final String CURRENCY_VALUE = 'CurrencyValue';
	public static final String THIRD_PARTY_CHARGES = 'TotalThirdPartyCharge';
    public static final String CARRIER_PARENT_NODE = 'TradingPartnerCarrier';
    public static final String CARRIER_NAME = 'TradingPartnerName';
    public static final String TRAILER_NUMBER = 'EquipmentNum';
	public static final String LOAD_NUM = 'LoadNum';
	public static final String INTERNAL_ID = 'InternalId';
	public static final String SUCCESS_COUNT = 'SuccessCount';

	//names of XML nodes for a Tms Stop object
	public static final Set<String> STOP_NODES = new Set<String> { 'StopNum', 'StopType' };

	//variables that are previously calculated from BOL__c values
	public static Set<String> BOL_CALCULATED_VALUES = new Set<String> {
		//calculated values for the Load and Order nodes
		'OrdNum',
		'LocNum1',
		'LocNum2',
		'OrderNum',
		'OriginLocNum',
		'PlannedArrival',
		'HandlingUnitNum',
		'TotalPieceCount',
		'DestinationLocNum',
		'TradingPartnerNum',
		'ScheduledLatePickup',
		'ScheduledLateDelivery',
		'TotalHandlingUnitCount',
		'TotalPieceCountPlanned',
		'TotalPieceCountPlanned1',
		'TotalHandlingUnitCountPlanned',

		'PieceCount1',
		'PieceCountPlanned1',
		'HandlingUnitCountPlanned1',

		'WeightValue',

		//calculated values for the Location node
		'Addr11',
		'Addr12',
		'AddrName1',
		'AddrName2',
		'CityName1',
		'CityName2',
		'StateCode1',
		'StateCode2',
		'PostalCode1',
		'PostalCode2',
		'CountryISO21',
		'CountryISO22'
//		'TradingPartnerNum1',
//		'TradingPartnerNum2'
	};

	//Map of nodes to their uom attribute values
	public static final Map<String, String> NODE_UNIT_OF_MEASUREMENT = new Map<String, String>{
		'WeightBase' => 'Lb',
		'WeightValue' => 'Lb',
		'DistanceValue' => 'Mi',
		'VolumeValue' => 'CuFt',
		'DimensionValue' => 'In',
		'CurrencyValue' => 'USD'
	};

	//DateTime fields in the BOL__c SF object that need to be formatted
	public static final Set<String> DATE_FIELDS = new Set<String>{
		'Pickup__c',
		'Dropoff__c'
	};


	/* ----------------- TMS Load Constants ----------------- */
	public static final String LOADS = 'LoadData';
	public static final String IMPORT_LOADS_RESPONSE = 'ImportLoadsResponse';
	public static final Set<String> BOL_ROOT_NODES = new Set<String> { 'Loads', 'Orders', 'Locs' };

	//Map of each node in Load POST to TMS (with their child nodes)
	public static final Map<String, List<String>> BOL_NODES_WITH_CHILD_NODES = new Map<String, List<String>>{
		'Loads' => new List<String> { 'Load' },
		'Load' => new List<String> {
			'OrganizationName',
			'LoadNum',
			'TotalGrossWeight',
			'TotalNetWeight',
			'TotalGrossVolume',
			'TotalNetVolume',
			'TotalHandlingUnitCount',
			'LoadTMSStatus',
			'OrderNums',
			'LoadHandlingUnits',
			'Stops'
		},

		'TotalNetFreightCost' => new List<String> { 'CurrencyValue' },
		'TotalNetAccessorialCost' => new List<String> { 'CurrencyValue' },
		'TotalNetCost' => new List<String> { 'CurrencyValue' },
		'TotalFreightValue' => new List<String> { 'CurrencyValue' },
		'TotalDistance' => new List<String> { 'DistanceValue' },
		'TotalGrossWeight' => new List<String> { 'WeightValue', 'WeightBase' },
		'TotalNetWeight' => new List<String> { 'WeightValue', 'WeightBase' },
		'TotalGrossVolume' => new List<String> { 'VolumeValue' },
		'TotalNetVolume' => new List<String> { 'VolumeValue' },
		'TotalNetOrdCharge' => new List<String> { 'CurrencyValue' },
		'NetProfit' => new List<String> { 'CurrencyValue' },
		'TradingPartnerCarrier' => new List<String> { 'OrganizationName', 'TradingPartnerName', 'TradingPartnerNum', 'TradingPartnerType' },
		'OrderNums' => new List<String> { 'OrderNum' },

		'LoadComments' => new List<String> { 'Comment' },
		'Comment' => new List<String> { 'Qualifier', 'CommentValue' },
		'Qualifier' => new List<String> { 'QualifierName', 'QualifierType' },

		'LoadHandlingUnits' => new List<String> { 'LoadHandlingUnit' },
		'LoadHandlingUnit' => new List<String> { 'HandlingUnit', 'StopNumPickup', 'StopNumDelivery' },
		'HandlingUnit' => new List<String> { 'HandlingUnitNum', 'TotalWeightGrossPlanned', 'TotalWeightNetPlanned', 'TotalVolumeGrossPlanned', 'TotalVolumeNetPlanned', 'TotalPieceCountPlanned', 'TotalHandlingUnitCountPlanned', 'HandlingUnitLines' },
		'TotalWeightGrossPlanned' => new List<String> { 'WeightValue', 'WeightBase' },
		'TotalWeightNetPlanned' => new List<String> { 'WeightValue', 'WeightBase' },
		'TotalVolumeGrossPlanned' => new List<String> { 'VolumeValue' },
		'TotalVolumeNetPlanned' => new List<String> { 'VolumeValue' },
		'HandlingUnitLines'	=> new List<String> { 'HandlingUnitLine', 'HandlingUnitLine' },
		'HandlingUnitLine' => new List<String> { 'OrdNum', 'OrdLineNum', 'WeightGrossPlanned', 'WeightNetPlanned', 'VolumeGrossPlanned','VolumeNetPlanned', 'PieceCountPlanned', 'HandlingUnitCountPlanned' },
		'WeightGrossPlanned' => new List<String> { 'WeightValue', 'WeightBase' },
		'WeightNetPlanned' => new List<String> { 'WeightValue', 'WeightBase' },
		'VolumeGrossPlanned' => new List<String> { 'VolumeValue' },
		'VolumeNetPlanned' => new List<String> { 'VolumeValue' },

		'Stops' => new List<String> { 'Stop', 'Stop' }, //one Pickup stop, one Delivery Stop
		'Stop' => new List<String> { 'StopNum', 'StopType', 'PlannedArrival', 'TotalWeightGrossPlanned', 'TotalWeightNetPlanned', 'TotalVolumeGrossPlanned', 'TotalVolumeNetPlanned', 'TotalPieceCountPlanned', 'TotalHandlingUnitCountPlanned', 'LocNum', 'OrderNums' },
		'TotalWeightGrossPlanned' => new List<String> { 'WeightValue', 'WeightBase' },
		'TotalWeightNetPlanned' => new List<String> { 'WeightValue', 'WeightBase' },
		'TotalVolumeGrossPlanned' => new List<String> { 'VolumeValue' },
		'TotalVolumeNetPlanned' => new List<String> { 'VolumeValue' },
		'OrderNums' => new List<String> { 'OrderNum' },

		'Orders' => new List<String> { 'Order' },
		'Order' => new List<String> {
			'OrganizationName',
			'OrdNum',
			'ScheduledLatePickup',
			'ScheduledLateDelivery',
			'TotalGrossWeight',
			'TotalNetWeight',
			'TotalGrossVolume',
			'TotalNetVolume',
			'TotalPieceCount',
			'TotalHandlingUnitCount',
			'OrdType',
			'OriginLocNum',
			'DestinationLocNum',
			'Client',
			'OrderLines',
			'OrderRefNums'
		},
		'Client' => new List<String> { 'OrganizationName', 'TradingPartnerName', 'TradingPartnerNum', 'TradingPartnerType' },
		'OrderLines' => new List<String> { 'OrderLine', 'OrderLine' },
		'OrderLine' => new List<String> { 'OrdLineNum', 'WeightGross', 'WeightNet', 'VolumeGross', 'VolumeNet', 'PieceCount', 'HandlingUnitCount' },
		'WeightGross' => new List<String> { 'WeightValue', 'WeightBase' },
		'WeightNet' => new List<String> { 'WeightValue', 'WeightBase' },
		'VolumeGross' => new List<String> { 'VolumeValue' },
		'VolumeNet' => new List<String> { 'VolumeValue' },

		'Locs' => new List<String> { 'Loc', 'Loc' },
		'Loc' => new List<String> { 'OrganizationName', 'TradingPartnerNum', 'TradingPartnerType', 'LocNum', 'LocationType', 'AddrName', 'Addr1', 'CityName', 'StateCode', 'PostalCode', 'CountryISO2' }
	};

	public static final Map<String, String> BOL_DEFAULT_VALUES = new Map<String, String> {
		'StopNumPickup' => '1',
		'StopNumDelivery' => '2',
		'HandlingUnitNum' => '0',
		'OrganizationName' => 'Smart_Pallets',

		'StopNum1' => '1',
		'StopNum2' => '2',
		'StopType1' => 'Pickup',
		'StopType2' => 'Delivery',

		'LoadTMSStatus' => 'Planned', //Planned, Provisional, Released, Assigned, Offered, Tendered, Declined, Accepted, InTransit, Shipped, Delivered, Canceled, OnHold, Complete, Closed, TenderExpired, BroadcastTendered, Unschedule
        'TradingPartnerType' => 'Client',
		'TradingPartnerType1' => 'Client', //Master, Client, Carrier, Vendor, Customer, Division
		'TradingPartnerType2' => 'Client',
		'Flex1TotalPlanned' => '0.00',
		'Flex2TotalPlanned' => '0.00',
		'OrdLineNum' => '1',
		'OrdLineNum1' => '1',
		'OrdLineNum2' => '2',
		'IsHazmatPlanned' => 'false',
		'Flex1Planned' => '0',
		'Flex2Planned' => '0',
		'PieceCount' => '0',
		'PieceCount2' => '0',
		'HandlingUnitCount' => '0',
		'PieceCountPlanned2' => '0',
		'TotalPieceCountPlanned2' => '0',
		'HandlingUnitCountPlanned2' => '0',

		'OrdType' => 'Planning',
		'LocationType1' => 'ShipReceive', //ShipReceive, ConsolidationPoint, CrossdockPool, Throughpoint, Terminal, MultiPurpose, AdminOnly
		'LocationType2' => 'ShipReceive',
		'TradingPartnerNum1' => 'Smart Logistics',
		'TradingPartnerNum2' => 'Smart Logistics'
	};


	/* ----------------- TMS Trading Partner Constants ----------------- */
	public static final String TRADING_PARTNER = 'TradingPartnerData';
	public static final Set<String> TRADING_PARTNER_ROOT_NODES = new Set<String> { 'TradingPartners' };

	public static final Map<String, String> TRADING_PARTNER_DEFAULT_VALUES = new Map<String, String> {
		'Currency' => 'USD',
		'IsActive' => 'true',
        'TradingPartnerNum' => 'Smart Logistics',
        'TradingPartnerName' => 'Smart Logistics',
		'TradingPartnerType' => 'Client',
		'DoNotAllowMultistop' => 'false',
		'OrganizationName' => 'Smart_Pallets',
		'IncludeNonClientSpecificCommodities' => 'true'
	};

	public static final Set<String> TRADING_PARTNER_CALCULATED_VALUES = new Set<String> {
		'DateCreated',
		'DateLastModified'
	};

	public static final Map<String, List<String>> TRADING_PARTNER_NODES_WITH_CHILD_NODES = new Map<String, List<String>> {
		'TradingPartners' => new List<String> { 'TradingPartner' },
		'TradingPartner' => new List<String> {
			'EntityHeader',
			'OrganizationName',
			'TradingPartnerName',
			'TradingPartnerNum',
			'TradingPartnerType',
			'IsActive',
			'DoNotAllowMultistop',
			'IncludeNonClientSpecificCommodities',
			'Currency'
		},
		'EntityHeader' => new List<String> { 'DateCreated', 'CreatedBy', 'DateLastModified', 'LastModifiedBy' }
	};


	/* ----------------- Constants used when checking for duplicates ----------------- */
	public static final String LOC = 'Loc';
	public static final String LOC_NUM = 'LocNum';

	public static final String STOP = 'Stop';
	public static final String STOP_NUM = 'StopNum';

	public static final String ORDER_LINE = 'OrderLine';
	public static final String ORDER_LINE_NUM = 'OrdLineNum';

	public static final String HANDLING_UNIT_LINE = 'HandlingUnitLine';
	public static final String ORGANIZATION_NAME = 'OrganizationName';
	public static final String TRADING_PARTNER_NUM = 'TradingPartnerNum';

	public static final String PIECE_COUNT = 'PieceCount';
	public static final String PIECE_COUNT_PLANNED = 'PieceCountPlanned';
	public static final String TOTAL_PIECE_COUNT_PLANNED = 'TotalPieceCountPlanned';
	public static final String HANDLING_UNIT_COUNT_PLANNED = 'HandlingUnitCountPlanned';

}