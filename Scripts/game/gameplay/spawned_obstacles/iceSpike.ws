/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3IceSpike extends W3DurationObstacle
{
	
	
	
	private editable var 		damageValue 			: float; 		default damageValue = -1;
	private editable var		weaponSlot				: name;			default weaponSlot	= 'r_weapon';
	private var 				canBeDestroyed			: bool;
	private var					destroyAfterTime		: float;
	private var					delayToDealDamage		: float;
	
	default destroyAfterTime 	= 3;
	default delayToDealDamage 	= 0.2f;	
	
	hint damageValue	= "either take l_damageAction from damageValue or weaponSlot";
	hint weaponSlot 	= "either take l_damageAction from damageValue or weaponSlot";
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var i					: int;
		var l_destructible		: CDestructionSystemComponent;
		var l_drawableCmps 		: array<CComponent>;
		var l_cmp 				: CDrawableComponent;
		
		super.OnSpawned( spawnData );
		
		l_destructible = (CDestructionSystemComponent) GetComponentByClassName('CDestructionSystemComponent');		
		if( l_destructible )
		{
			canBeDestroyed = true;
		}
		
		if( destroyAfterTime > 0 )
		{
			DestroyAfter( destroyAfterTime );
		}
		
		
		
		Appear();
	}
	
	
	private timer function Appear( optional _Delta : float, optional id : int)
	{		
		PlayEffect('appear');		
		AddTimer( 'DealDamage', delayToDealDamage, false,,, true );
	}	
	
	
	private timer function DealDamage( optional _Delta : float, optional id : int)
	{
		var i						: int;
		var l_actorsRange			: array <CActor>;
		var l_range					: float;
		var l_actor					: CActor;
		var none					: SAbilityAttributeValue;
		var l_damageAction			: W3DamageAction;
		var l_summonedEntityComp 	: W3SummonedEntityComponent;
		var	l_summoner				: CActor;	
		var l_damageAttr 			: SAbilityAttributeValue;
		var l_inv					: CInventoryComponent;
		var l_weaponId 				: SItemUniqueId;
		var l_damageValue			: float;
		var l_damageNames			: array < CName >;
		var l_attribute				: name;
		
		
		l_summonedEntityComp = (W3SummonedEntityComponent) GetComponentByClassName('W3SummonedEntityComponent');
		
		if( !l_summonedEntityComp )
		{
			return;
		}
		
		l_summoner = l_summonedEntityComp.GetSummoner();
		
		l_range = 0.3f;
		l_actorsRange = GetActorsInRange( this, l_range, -1, , true );
		
		for	( i = 0; i < l_actorsRange.Size(); i += 1 )
		{
			l_actor = (CActor) l_actorsRange[i];
			
			if ( l_actor == l_summoner ) continue;
			
			l_damageAction = new W3DamageAction in this;
			l_damageAction.Initialize( l_summoner, l_actor, l_summoner, l_summoner.GetName(), EHRT_Heavy, CPS_Undefined, false, false, false, true );			
			
			l_summoner.GetVisualDebug().AddSphere('DetectionRange', l_range, GetWorldPosition(), true);
			l_summoner.GetVisualDebug().AddText('DetectionRangeText', "Ice", GetWorldPosition(), true);
			
			if( l_summoner && IsNameValid( weaponSlot ) )
			{
				l_inv 		= l_summoner.GetInventory();		
				l_weaponId 	= l_inv.GetItemFromSlot( weaponSlot );
				l_inv.GetWeaponDTNames( l_weaponId, l_damageNames );
				l_attribute = GetBasicAttackDamageAttributeName( theGame.params.ATTACK_NAME_HEAVY, theGame.params.DAMAGE_NAME_FROST);
				l_damageAttr = l_summoner.GetAttributeValue( l_attribute );
				l_damageAttr.valueBase  = l_summoner.GetTotalWeaponDamage( l_weaponId, l_damageNames[0], GetInvalidUniqueId() );
				l_damageValue = l_damageAttr.valueBase * l_damageAttr.valueMultiplicative + l_damageAttr.valueAdditive;
				
				if( l_damageValue > 0 )
				{
					l_damageAction.AddDamage( theGame.params.DAMAGE_NAME_FROST, l_damageValue );
				}
				else
				{
					l_damageAction.AddDamage( theGame.params.DAMAGE_NAME_PHYSICAL, damageValue );
				}
			}
			else
			{
				l_damageAction.AddDamage( theGame.params.DAMAGE_NAME_PHYSICAL, damageValue );
			}
			
			theGame.damageMgr.ProcessAction( l_damageAction );
			delete l_damageAction;
		}
	}
	
	
	event OnAardHit( sign : W3AardProjectile )
	{
		if( canBeDestroyed )
		{
			ShowDestructible();
			DestroyAfter( 1.5f );
		}
	}
	private function SpecificDisappear()
	{	
		canBeDestroyed = false;
	}
	
	
	private function ShowDestructible( )
	{
		var l_destructible			: CDestructionSystemComponent;
		var l_mesh					: CMeshComponent;
		
		l_destructible = (CDestructionSystemComponent) GetComponentByClassName('CDestructionSystemComponent');
		l_destructible.SetVisible( true );
		
		l_mesh = (CMeshComponent) GetComponentByClassName('CMeshComponent');
		if( l_mesh )
		{
			l_mesh.SetVisible( false );
		}
	}
}