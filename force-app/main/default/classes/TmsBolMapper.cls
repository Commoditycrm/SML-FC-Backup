/**
 * @author RadialSpark
 * @date 05-01-2018
 * @description Mapper used to map between Salesforce BOL__c and TMS Load objects (methods in TmsMapper class)
 * @changelog
	05-01-2018 - Bradley Wong - Created
	05-24-2018 - Bradley Wong - added wrapper class to allow for extra fields that are not in BOL__c SF object
	06-05-2018 - Bradley Wong - added method to set specific values based on BOL__c field
	06-14-2018 - Bradley wong - moved buildBolValueMapper() from TmsIntegrationService to TmsBolMapper
 */

 //questions totalhandlingunitcount vs totalpiececount

public class TmsBolMapper extends TmsMapper {

	public TmsBolMapper() {
		sfFieldsToTmsFields = new Map<String, String> {
			'Name' => 'LoadNum',
			'Pickup__c' => 'PlannedStart', //need to convert String values from XML to DateTime
			'Dropoff__c' => 'PlannedEnd', //need to convert String values from XML to DateTime
			'Total_Pallets__c' => 'TotalHandlingUnitCount'
		};

		tmsFieldsToSfFields = new Map<String, String> {
			'LoadNum' => 'Name',
			'PlannedEnd' => 'Dropoff__c',
			'PlannedStart' => 'Pickup__c',
			'PieceCount' => 'Total_Pallets__c',
			'PieceCountPlanned' => 'Total_Pallets__c',
			'TotalHandlingUnitCount' => 'Total_Pallets__c'
		};
	}

	/**
	 * @description If there are pre-calculated values from the BOL__c object ==> set as values in mapper
	 */
	private void setBolValues(Map<String, String> thisBolValues) {
		for (String prop : thisBolValues.keySet()) {
			if (prop == 'WeightValue') System.debug('WEIGHT VALUE IN SETTING BOL VALUES: ' + thisBolValues.get(prop));
			this.tmsFieldsToSfFields.put(prop, thisBolValues.get(prop));
		}
	}


	/**
	 * @description Builds a value mapper with properly formatted data from a BOL__c object
	 */
	public void buildBolValueMapper(BOL__c bol) {
		//format the pickup and dropoff dates appropriately
		String arrivalTime = DateTimeUtility.toString(bol.Dropoff__c);
		String departureTime = DateTimeUtility.toString(bol.Pickup__c);

		//set Location Name values based on BOL Name
		String pickupLocation = bol.Name + '-Pickup_Location';
		String deliveryLocation = bol.Name + '-Delivery_Location';

		String totalPallets = String.valueOf(bol.Total_Pallets__c);

		String grossWeight = String.valueOf(bol.Total_Pallets__c * ConstantsUtility.SINGLE_PALLET_WEIGHT);

		//constant values derived from the BOL values for use in the XML string
		Map<String, String> thisBolValues = new Map<String, String> {
			'LocNum1' => pickupLocation,
			'LocNum2' => deliveryLocation,
			'OriginLocNum' => pickupLocation,
			'DestinationLocNum' => deliveryLocation,

			'TradingPartnerNum' => 'Smart Logistics',
			'TotalPieceCount' => totalPallets,
			'TotalPieceCountPlanned' => totalPallets,
			'TotalPieceCountPlanned1' => totalPallets,
			'TotalHandlingUnitCount' => totalPallets,
			'TotalHandlingUnitCountPlanned' => totalPallets,
			'PieceCount1' => totalPallets,
			'PieceCountPlanned1' => totalPallets,
			'HandlingUnitCountPlanned1' => totalPallets,

			'WeightValue' => grossWeight,

			'OrdNum' => bol.Name + '-Order',
			'OrderNum' => bol.Name + '-Order',
			'HandlingUnitNum' => bol.Name + '-HandlingUnit',

			'PlannedArrival' => arrivalTime,
			'ScheduledLatePickup' => departureTime,
			'ScheduledLateDelivery' => arrivalTime,

			// 'TradingPartnerNum1' => String.valueOf(bol.Source_Location__c),
			// 'TradingPartnerNum2' => String.valueOf(bol.Target_Location__c),
//			'TradingPartnerNum1' => bol.Carrier__c,
//			'TradingPartnerNum2' => bol.Carrier__c,

			'AddrName1' => bol.Source_Location__r.Name,
			'Addr11' => bol.Source_Location__r.ShippingAddress.getStreet(),
			'CityName1' => bol.Source_Location__r.ShippingAddress.getCity(),
			'StateCode1' => bol.Source_Location__r.ShippingState,
			'PostalCode1' => bol.Source_Location__r.ShippingAddress.getPostalCode(),
			'CountryISO21' => toCountryCode(bol.Source_Location__r.ShippingCountry),

			'AddrName2' => bol.Target_Location__r.Name,
			'Addr12' => bol.Target_Location__r.ShippingAddress.getStreet(),
			'CityName2' => bol.Target_Location__r.ShippingAddress.getCity(),
			'StateCode2' => bol.Target_Location__r.ShippingState,
			'PostalCode2' => bol.Target_Location__r.ShippingAddress.getPostalCode(),
			'CountryISO22' => toCountryCode(bol.Target_Location__r.ShippingCountry)
		};

		this.setBolValues(thisBolValues);
	}

	/**
	 * @description Converts country name to Country Code
	 */
	private static String toCountryCode(String countryName) {
		Country_ISO_Code__mdt countryCode;
		try {
			countryCode = [
				SELECT
					Country_Name__c,
					Country_Code__c
				FROM Country_ISO_Code__mdt
				WHERE Country_Name__c = :countryName
				LIMIT 1
			];
		} catch (QueryException e) {
			//Test classes do not have access to custom metadata instances ==> will throw this exception
		}

		if (countryCode == null) throw new CalloutException('Country Code is invalid. Country Name: ' + countryName);
		return countryCode.Country_Code__c;
	}

}