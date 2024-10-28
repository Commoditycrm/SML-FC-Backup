/**
 * @author RadialSpark
 * @date 05-02-2018
 * @description Test class for TmsBolMapper class
 * @changelog
	05-02-2018 - Bradley Wong - created
	06-14-2018 - Bradley Wong - updated tests for new Mapper
 */

@isTest
private class TmsBolMapperTest {
	private static Map<String, String> sfBolPayload;
	private static Map<String, String> tmsBolPayload;

	private static void init() {
		sfBolPayload = new Map<String, String> {
			'Name' => 'LOAD_NAME',
			'Pickup__c' => 'START', //need to convert String values from XML to DateTime
			'Dropoff__c' => 'END', //need to convert String values from XML to DateTime
			'Total_Pallets__c' => 'TOTAL_PALLETS'		
		}; 
		
		tmsBolPayload = new Map<String, String> {
			'LoadNum' => 'LOAD_NAME',
			'PlannedEnd' => 'END',
			'PlannedStart' => 'START',
			'TotalHandlingUnitCount' => 'TOTAL_PALLETS'
		};
	}

	private testmethod static void mapToSf_ShouldMapTmsBolPayloadToSfBolPayload() {
		init();

		TmsBolMapper tmsMapper = new TmsBolMapper();

		System.Test.startTest();
		Map<String, String> mappedPayload = tmsMapper.mapToSf(tmsBolPayload);
		System.Test.stopTest();

		System.assertEquals(sfBolPayload, mappedPayload);
	}

	private testmethod static void mapToTms_ShouldMapSfBolPayloadToTmsBolPayload() {
		init();

		TmsBolMapper tmsMapper = new TmsBolMapper();

		System.Test.startTest();
		Map<String, String> mappedPayload = tmsMapper.mapToTms(sfBolPayload);
		System.Test.stopTest();

		System.assertEquals(tmsBolPayload, mappedPayload);
	}
}