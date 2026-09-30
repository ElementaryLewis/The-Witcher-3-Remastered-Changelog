/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EMerchantMapPinType
{
	EMMPT_Shopkeeper,
	EMMPT_Blacksmith,
	EMMPT_Armorer,
	EMMPT_BoatBuilder,
	EMMPT_Hairdresser,
	EMMPT_Herbalist,
	EMMPT_Alchemist,
	EMMPT_Innkeeper,
	EMMPT_Enchanter,
	EMMPT_DyeTrader,
	EMMPT_WineTrader,
	EMMPT_Cammerlengo
}

class W3MerchantComponent extends CScriptedComponent
{
	editable var mapPinType : EMerchantMapPinType;
	default mapPinType = EMMPT_Shopkeeper;

	public function GetMapPinType() : name
	{
		switch( mapPinType )
		{
			case EMMPT_Shopkeeper:
				return 'Shopkeeper';
			case EMMPT_Blacksmith:
				return 'Blacksmith';
			case EMMPT_Armorer:
				return 'Armorer';
			case EMMPT_BoatBuilder:
				return 'BoatBuilder';
			case EMMPT_Hairdresser:
				return 'Hairdresser';
			case EMMPT_Alchemist:
				return 'Alchemic';
			case EMMPT_Herbalist:
				return 'Herbalist';
			case EMMPT_Innkeeper:
				return 'Innkeeper';
			case EMMPT_Enchanter:
				return 'Enchanter';
			case EMMPT_DyeTrader:
				return 'DyeMerchant';
			case EMMPT_WineTrader:
				return 'WineMerchant';
			case EMMPT_Cammerlengo:
				return 'Cammerlengo';
		}
		return '';
	}

	
	public function  GetScriptInfo( type : name, cacheable : bool )
	{
		var merchantNPC : W3MerchantNPC;

		merchantNPC = (W3MerchantNPC)GetEntity();

		
		type = GetMapPinType();
		
		
		cacheable = merchantNPC.cacheMerchantMappin;
	}
};
