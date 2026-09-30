/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskExplodeAtDeath extends IBehTreeTask
{
	
	
	
	public  var requiredAbility		: name;
	public 	var damageRadius		: float;
	public  var damageValue			: float;
	public  var weaponSlot			: name;
	
	private var m_hasExploded		: bool;
	
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( IsNameValid( requiredAbility ) && !GetNPC().HasAbility( requiredAbility ) )
			return false;
		if( !m_hasExploded && ( eventName == 'Death' || eventName == 'FinisherKill' ) )
		{			
			Explode();
		}
		return true;
	}
	
	
	private function Explode()
	{
		var l_actor 				: CActor;	
		var l_dismembermentComp 	: CDismembermentComponent;
		var l_wounds				: array< name >;
		var l_actors				: array< CActor >;
		var l_usedWound				: name;
		var i						: int;
		var l_damageAction			: W3DamageAction;
		
		var l_damageAttr 			: SAbilityAttributeValue;
		var l_inv					: CInventoryComponent;
		var l_weaponId 				: SItemUniqueId;
		var l_damageNames			: array < CName >;
		var l_attribute				: name;
		
		l_actor = GetNPC();
		
		l_dismembermentComp = (CDismembermentComponent)(l_actor.GetComponentByClassName( 'CDismembermentComponent' ));
		if(!l_dismembermentComp) return;
		
		l_dismembermentComp.GetWoundsNames( l_wounds, WTF_Explosion );
		
		if ( l_wounds.Size() > 0 )
						l_usedWound = l_wounds[ RandRange( l_wounds.Size() ) ];
						
		l_actor.SetDismembermentInfo( l_usedWound, Vector( 0, 0, 10 ), false );
		l_actor.AddTimer( 'DelayedDismemberTimer', 0.05f );
		
		m_hasExploded = true;
		
		l_actor.GetVisualDebug().AddSphere( 'ExplosionRange', damageRadius, Vector(0,0,0),,,5 );
		
		if( damageRadius > 0 )
		{
			l_actors = GetActorsInRange(  GetNPC(), damageRadius, -1,, true );
			
			if( l_actors.Size() > 0 )
			{
				l_damageAction = new W3DamageAction in this;
				
				if( IsNameValid( weaponSlot ) )
				{
					l_inv 		= l_actor.GetInventory();		
					l_weaponId 	= l_inv.GetItemFromSlot( weaponSlot );
					l_inv.GetWeaponDTNames( l_weaponId, l_damageNames );
					l_attribute = GetBasicAttackDamageAttributeName( theGame.params.ATTACK_NAME_HEAVY, theGame.params.DAMAGE_NAME_FROST);
					l_damageAttr = l_actor.GetAttributeValue( l_attribute );
					l_damageAttr.valueBase  =l_actor.GetTotalWeaponDamage( l_weaponId, l_damageNames[0], GetInvalidUniqueId() );
					
					if ( theGame.GetDifficultyMode() == EDM_Easy )     damageValue = 50  + ( ( l_damageAttr.valueBase * l_damageAttr.valueMultiplicative + l_damageAttr.valueAdditive ) * 2 ); else
					if ( theGame.GetDifficultyMode() == EDM_Hard )     damageValue = 150 + ( ( l_damageAttr.valueBase * l_damageAttr.valueMultiplicative + l_damageAttr.valueAdditive ) * 4 ); else
					if ( theGame.GetDifficultyMode() == EDM_Hardcore ) damageValue = 200 + ( ( l_damageAttr.valueBase * l_damageAttr.valueMultiplicative + l_damageAttr.valueAdditive ) * 5 ); else
																	   damageValue = 100 + ( ( l_damageAttr.valueBase * l_damageAttr.valueMultiplicative + l_damageAttr.valueAdditive ) * 3 );
				}
				
				for	( i = 0; i < l_actors.Size(); i += 1 )
				{
					if( l_actors[i] == GetNPC() ) 
						continue;
						
					l_damageAction.Initialize( l_actor, l_actors[i], NULL, "Explosion", EHRT_Heavy, CPS_AttackPower, false, true, false, false );
					l_damageAction.SetCannotReturnDamage( true );
					
					l_damageAction.AddDamage(  theGame.params.DAMAGE_NAME_PHYSICAL, damageValue );
					l_damageAction.AddDamage(  theGame.params.DAMAGE_NAME_SILVER, damageValue );
					l_damageAction.AddEffectInfo( EET_Stagger, 1.0f );
					theGame.damageMgr.ProcessAction( l_damageAction );
					
				}
				
				delete( l_damageAction );
			}
		}		
	}

}




class BTTaskExplodeAtDeathDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskExplodeAtDeath';
	
	
	private editable var requiredAbility	: name;
	private editable var damageRadius		: float;
	private editable var damageValue		: float;
	private editable var weaponSlot			: name;
	
	default damageRadius 	= 5;
	default damageValue 	= 50;
	
	hint damageValue = "damage if weapon slot is not set";
	
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'Death' );
		listenToGameplayEvents.PushBack( 'FinisherKill' );
	}
}
