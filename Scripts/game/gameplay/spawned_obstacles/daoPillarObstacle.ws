/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3DaoPillarObstacle extends W3DurationObstacle
{
	
	
	
	private editable var 		damageValue 			: float; 		default damageValue = 100;
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
		
		AddTimer( 'Appear', 0.5f );
	}
	
	
	private timer function Appear( _Delta : float, optional id : int)
	{
		var i						: int;
		var l_entitiesInRange		: array <CGameplayEntity>;
		var l_range					: float;
		var l_actor					: CActor;
		var none					: SAbilityAttributeValue;
		var l_damage				: W3DamageAction;
		var l_summonedEntityComp 	: W3SummonedEntityComponent;
		var	l_summoner				: CActor;	
		
		l_summonedEntityComp = (W3SummonedEntityComponent) GetComponentByClassName('W3SummonedEntityComponent');
		
		if( !l_summonedEntityComp )
		{
			return;
		}
		
		l_summoner = l_summonedEntityComp.GetSummoner();
		
		l_range = 1;
		
		PlayEffect('circle_stone');
		
		FindGameplayEntitiesInRange( l_entitiesInRange, this, l_range, 1000);
		
		for	( i = 0; i < l_entitiesInRange.Size(); i += 1 )
		{
			l_actor = (CActor) l_entitiesInRange[i];
			if( !l_actor ) continue;
			
			if ( l_actor == l_summoner ) continue;
			
			l_damage = new W3DamageAction in this;
			l_damage.Initialize( l_summoner, l_actor, l_summoner, l_summoner.GetName(), EHRT_Heavy, CPS_Undefined, false, false, false, true );
			l_damage.AddDamage( theGame.params.DAMAGE_NAME_PHYSICAL, damageValue );
			l_damage.AddEffectInfo( EET_KnockdownTypeApplicator, 1);
			theGame.damageMgr.ProcessAction( l_damage );
			delete l_damage;
		}
	}
}