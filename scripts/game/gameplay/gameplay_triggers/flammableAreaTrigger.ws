/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3FlammableAreaTrigger extends W3EffectAreaTrigger
{
	public editable var activeFor : float;
	public editable var fxOnExplosion : name;
	public editable var fxOnSustain : name;
	public editable var explosionRange : float;
	public editable var explosionDamage : SAbilityAttributeValue;
	public editable var igniteFlammableAreasAfter : float;
	
	private var isActive : bool;
	private var area : CTriggerAreaComponent;
	
	default effect = EET_Burning;
	default activeFor = 10.0;
	default fxOnExplosion = 'explosion';
	default fxOnSustain = 'fire';
	default explosionRange = 10.0;
	default igniteFlammableAreasAfter = 0.5;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		area = (CTriggerAreaComponent)GetComponentByClassName( 'CTriggerAreaComponent' );
	}
	
	public function Ignite()
	{
		if( IsActive() )
			return;
			
		SetActive( true );
		Explode();
		PlayEffect( fxOnSustain );
		
		if( activeFor > 0.0 )
		{
			AddTimer( 'Extinguish', activeFor );
		}
	}
	
	private function Explode()
	{
		var i : int;
		var entitiesInRange : array<CGameplayEntity>;
		var damage : W3DamageAction;
		var actor : CActor;
		var dmgVal  : float;
		var flammableArea : W3FlammableAreaTrigger;
		
		PlayEffect( fxOnExplosion );
		GCameraShake( 0.5, true, GetWorldPosition(), explosionRange );
				
		area.GetGameplayEntitiesInArea( entitiesInRange, explosionRange );
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			actor = (CActor)entitiesInRange[i];
			if( actor )
			{
				damage = new W3DamageAction in this;
				damage.Initialize( this, entitiesInRange[i], this, this, EHRT_None, CPS_Undefined, false, false, false, true );
				dmgVal = explosionDamage.valueAdditive + explosionDamage.valueMultiplicative * actor.GetMaxHealth();
				damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmgVal );
				damage.AddEffectInfo( EET_KnockdownTypeApplicator );
				
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
			}
			else
			{
				flammableArea = (W3FlammableAreaTrigger)entitiesInRange[i];
				if( flammableArea )
				{
					flammableArea.AddTimer( 'OnFireHitAfter', igniteFlammableAreasAfter );
				}
				else
				{
					entitiesInRange[i].OnFireHit( this );
				}
			}
		}
	}
	
	timer function Extinguish( td : float, id : int )
	{
		StopAllEffects();
		SetActive( false );
		RemoveTimer( 'ProcessArea' );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( !IsActive() )
		{
			if( activator.GetEntity().HasTag( theGame.params.TAG_OPEN_FIRE ) )
			{
				Ignite();
			}
			else
			{
				return false;
			}
		}
		
		super.OnAreaEnter( area, activator );
	}
	
	event OnFireHit( source : CGameplayEntity )
	{
		if( IsActive() )
			return false;
			
		super.OnFireHit( source );

		Ignite();		
	}
	
	timer function OnFireHitAfter( td : float, id : int )
	{
		OnFireHit( this );		
	}
	
	private function IsActive() : bool { return isActive; }
	private function SetActive( val : bool ) { isActive = val; }
}