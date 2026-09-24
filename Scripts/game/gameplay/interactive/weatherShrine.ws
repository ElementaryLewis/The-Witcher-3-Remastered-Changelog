/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3WeatherShrine extends CGameplayEntity
{
	editable var weatherBlendTime : float;
	editable var cooldown : float;
	editable var prayerForSunAcceptedFX : name;
	editable var prayerForStormAcceptedFX : name;
	
	editable var price : int;
	
	default weatherBlendTime = 60.f;
	default price = 1;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
		if ( cooldown < weatherBlendTime )
			cooldown = weatherBlendTime;
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( actionName == "PrayForSun" )
		{
			if ( ChangeWeatherTo('WT_Clear') )
				ChangingWeatherStarted();
		}
		else if ( actionName == "PrayForStorm" )
		{
			if ( ChangeWeatherTo('WT_Rain_Storm') )
				ChangingWeatherStarted();
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		var currentWeather : name = GetWeatherConditionName();
		
		
		if ( thePlayer.GetInventory().GetMoney() < price )
			return false;
		
		if ( interactionComponentName == "PrayForSun" )
		{
			return currentWeather != 'WT_Clear';
		}
		else if ( interactionComponentName == "PrayForStorm" )
		{
			return currentWeather != 'WT_Rain_Storm';
		}
		
		return false;
	}
	
	private function ChangeWeatherTo( newWeather : name ) : bool
	{
		if ( RequestWeatherChangeTo(newWeather, weatherBlendTime, false) )
		{
			thePlayer.DisplayHudMessage( GetLocStringByKeyExt( "panel_hud_message_prayer_heard" ) );
			if ( prayerForSunAcceptedFX )
				PlayEffect( prayerForSunAcceptedFX );
			return true;
		}
		else
		{
			thePlayer.DisplayHudMessage( GetLocStringByKeyExt ("panel_hud_message_prayer_not_heard" ) );
			if ( prayerForStormAcceptedFX )
				PlayEffect( prayerForStormAcceptedFX );
			return false;
		}
	}
	
	private function ChangingWeatherStarted()
	{
		thePlayer.GetInventory().RemoveMoney(price);
		GetComponent("PrayForSun").SetEnabled(false);
		GetComponent("PrayForStorm").SetEnabled(false);
		AddTimer('EnableInteracitons',cooldown,false, , , true);
	}
	
	private timer function EnableInteracitons( dt : float , id : int)
	{
		GetComponent("PrayForSun").SetEnabled(true);
		GetComponent("PrayForStorm").SetEnabled(true);
	}
}