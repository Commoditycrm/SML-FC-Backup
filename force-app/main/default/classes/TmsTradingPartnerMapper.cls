/**
 * @author RadialSpark
 * @date 06-11-2018
 * @description Mapper used to map an Account SObject to a TMS TradingPartner
 * @changelog
	06-11-2018 - Bradley Wong - Created
 */

public class TmsTradingPartnerMapper {
	private Map<String, String> tradingPartnerValues;

	/**
	 * @description Sets the calculated TradingPartner values from SF Account
	 *  ==> Account.Id = TradingPartnerNum
	 * 	==> Account.Name = TradingPartnerName
	 */
	public TmsTradingPartnerMapper(Map<String, String> tradingPartnerValues) {	
		this.tradingPartnerValues = tradingPartnerValues;
	}

	public Map<String, String> getTradingPartnerValues() {
		return this.tradingPartnerValues;
	}
}