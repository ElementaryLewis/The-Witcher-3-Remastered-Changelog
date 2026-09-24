/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CHitBasedNPC extends CNewNPC
{
	editable var hitsToDeath : int;
	editable var minTimeBetweenHits : float;
	
	private var baseStat : EBaseCharacterStats;
	private var chunkValue : float;
	private var hitsTaken : int;
	private var lastHitTimestamp : float;
	private var wasInitialized : bool;
	
	default hitsToDeath = 5;
	default minTimeBetweenHits = 0.5;
	default hitsTaken = 0;
	default lastHitTimestamp = 0.0;

	private function Init()
	{
		if( UsesVitality() )
		{
			baseStat = BCS_Vitality;
		}
		else
		{
			baseStat = BCS_Essence;
		}
		
		if( !hitsToDeath )
		{
			hitsToDeath = 1;
		}
	
		chunkValue = GetStatMax( baseStat ) / hitsToDeath;
	}
	
	event OnTakeDamage( action : W3DamageAction )
	{
		if( action.attacker != thePlayer || !action.DealsAnyDamage() )
		{
			return false;
		}
		
		if( lastHitTimestamp + minTimeBetweenHits > theGame.GetEngineTimeAsSeconds() )
		{
			return false;
		}
		
		if( !wasInitialized )
		{
			Init();
		}
		
		hitsTaken += 1;
		
		if( hitsTaken >= hitsToDeath )
		{
			DrainStat( GetStat( baseStat ) - 1.0 );
			super.OnTakeDamage( action );
		}
		else
		{
			DrainStat( chunkValue );
		}
		
		lastHitTimestamp = theGame.GetEngineTimeAsSeconds();
	}
	
	private function DrainStat( val : float )
	{
		if( UsesVitality() )
		{
			DrainVitality( val );
		}
		else
		{
			DrainEssence( val );
		}
	}
}