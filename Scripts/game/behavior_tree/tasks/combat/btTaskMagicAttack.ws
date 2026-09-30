/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class CBTTaskCollisionAttack extends CBTTaskAttack
{
	function OnGameplayEvent( eventName : name ) : bool
	{
		var attackData : CPreAttackEventData;
		
		if ( eventName == 'NewCurrentAttackData' )
		{
			if ( GetActor().GetCurrentAttackData(attackData) )
				NewCurrentAttackData( attackData );
				
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
	
	function NewCurrentAttackData( attackData : CPreAttackEventData );
}

abstract class CBTTaskCollisionAttackDef extends CBTTaskAttackDef
{
}

abstract class CBTTaskMagicAttack extends CBTTaskCollisionAttack
{
	var dodgeable				: bool;
	var fxDummyEntityTag 		: name;
	var effectName 				: name;
	var dummyEntityEffectName 	: name;
	
	function OnDeactivate()
	{
		super.OnDeactivate();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res 			: bool;
		var fxDummyEntity 	: array<CEntity>;
		var target 			: CNode = GetCombatTarget();
		var actor			: CActor = GetActor();
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if ( !target )
		{
			target = GetActionTarget();
		}
		
		if ( animEventName == 'PerformMagicAttack' )
		{
			if ( dodgeable )
			{
				if ( target && !((CActor)target).IsCurrentlyDodging() )
				{
					PerformMagicAttack();
				}
				else
				{
					theGame.GetEntitiesByTag( fxDummyEntityTag, fxDummyEntity );
					if ( fxDummyEntity.Size() > 0 )
					{
						
						
						actor.PlayEffect( effectName, fxDummyEntity[0] );
						fxDummyEntity[0].PlayEffect( dummyEntityEffectName );
					}
				}
			}
			else
			{
				PerformMagicAttack();
			}
			
			
			return true;
		}
		
		return res;
	}
	
	function PerformMagicAttack();
	
}

abstract class CBTTaskMagicAttackDef extends CBTTaskCollisionAttackDef
{
	editable var dodgeable				: bool;
	editable var effectName	 			: name;
	editable var fxDummyEntityTag		: name;
	editable var dummyEntityEffectName 	: name;
	
	default dodgeable = true;
}

struct SFxOnAnimEvent
{
	editable var fxOnAnimEvent : name;
	editable var animEvent : name;
}


class CBTTaskMagicMeleeAttack extends CBTTaskMagicAttack
{
	public var resourceName 			: name;
	
	private var fxOnAnimEvent 			: array<SFxOnAnimEvent>;
	private var effectEntityTemplate 	: CEntityTemplate;
	private var entity 					: CEntity;
	private var dealDmgOnDeactivate 	: bool;
	private var couldntLoadResource 	: bool;
	private var effectHitName			: name;
	
	
	
	var foundPos			: bool;
	var pos					: Vector;
	var rot					: EulerAngles;
	
	default foundPos = false;
	
	function IsAvailable() : bool
	{
		return !couldntLoadResource;
	}
	
	latent function Main() : EBTNodeStatus
	{
		if ( !effectEntityTemplate )
			effectEntityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
		
		if ( !effectEntityTemplate )
		{
			couldntLoadResource = true;
			return BTNS_Failed;
		}
		
		super.Main();
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( dealDmgOnDeactivate )
		{
			GetActor().OnCollisionFromItem( GetCombatTarget() );
			dealDmgOnDeactivate = false;
		}
		
		foundPos = false;
		super.OnDeactivate();
	}
	
	function PerformMagicAttack()
	{
		dealDmgOnDeactivate = false;
		GetActor().OnCollisionFromItem( GetCombatTarget() );
	}
	
	function NewCurrentAttackData( attackData : CPreAttackEventData )
	{
		SpawnEffect(attackData);
		dealDmgOnDeactivate = true;
	}
	
	function SpawnEffect( attackData : CPreAttackEventData ) : bool
	{
		var effectName 	: name;
		
		
		
		switch ( attackData.swingType )
		{
			case AST_Horizontal:
			{
				switch ( attackData.swingDir )
				{
					case ASD_LeftRight: 	effectName = 'left'; effectHitName = 'blood_left';	break;
					case ASD_RightLeft: 	effectName = 'right'; effectHitName = 'blood_right'; 	break;
					default: break;
				}
				break;
			}
			case AST_Vertical:
			{
				switch ( attackData.swingDir )
				{
					case ASD_UpDown: 		effectName = 'down'; effectHitName = 'blood_down';	break;
					case ASD_DownUp: 		effectName = 'up'; effectHitName = 'blood_up';		break;
					default: break;
				}
				break;
			}
			case AST_DiagonalUp:
			{
				switch ( attackData.swingDir )
				{
					case ASD_LeftRight: 	effectName = 'diagonal_up_left'; effectHitName = 'blood_diagonal_up_left'; 	break;
					case ASD_RightLeft: 	effectName = 'diagonal_up_right'; effectHitName = 'blood_diagonal_up_right'; 	break;
					default: break;
				}
				break;
			}
			case AST_DiagonalDown:
			{
				switch ( attackData.swingDir )
				{
					case ASD_LeftRight: 	effectName = 'diagonal_down_left'; effectHitName = 'blood_diagonal_down_left';	break;
					case ASD_RightLeft: 	effectName = 'diagonal_down_right'; effectHitName = 'blood_diagonal_down_right';	break;
					default: break;
				}
				break;
			}
			default :					effectName = '';
		}
		
		if( GetActor().HasTag( 'Philippa' ) )
			effectName = 'cast_line';
		
		if( effectName )
		{
			if (!foundPos)
			{
				GetEffectPositionAndRotation(pos, rot);
				foundPos = true;
			}
			
			entity = theGame.CreateEntity( effectEntityTemplate, pos, rot );
			
			if ( entity )
			{
				entity.PlayEffect(effectName);
				entity.DestroyAfter(5.f);
				return true;
			}
		}
		return false;
	}
	
	function GetEffectPositionAndRotation( out pos : Vector, out rot : EulerAngles )
	{
		var target 	: CActor = GetCombatTarget();
		var owner 	: CActor = GetNPC();
		
		pos = target.GetWorldPosition();
		pos.Z += 0.7;
		rot = owner.GetWorldRotation();
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var witcher 	: W3PlayerWitcher = GetWitcherPlayer();
		var damageData	: W3DamageAction;
		
		if ( eventName == 'HitActionReaction' )
		{
			hitActionReactionEventReceived = true;
			hitTimeStamp = GetLocalTime();
			if ( hitActionReactionEventReceived && damageInstigatedEventReceived && IsNameValid( effectHitName ) 
				&& GetLocalTime() > fxTimeCooldown && GetLocalTime() < hitTimeStamp + 0.5 )
			{
				hitActionReactionEventReceived = false;
				damageInstigatedEventReceived = false;
				if ( witcher == GetCombatTarget() && ( witcher.IsQuenActive( true ) || witcher.IsQuenActive( false ) ) )
					return false;
				
				fxTimeCooldown = GetLocalTime() + applyFXCooldown;
				entity.PlayEffect(effectHitName);
			}
		}
		if ( eventName == 'DamageInstigated' )
		{
			damageData = ( W3DamageAction ) GetEventParamObject();
			if ( !damageData.IsDoTDamage() )
			{
				damageInstigatedEventReceived = true;
				hitTimeStamp = GetLocalTime();
				if ( hitActionReactionEventReceived && damageInstigatedEventReceived && IsNameValid( effectHitName ) 
					&& GetLocalTime() > fxTimeCooldown && GetLocalTime() < hitTimeStamp + 0.5 )
				{
					hitActionReactionEventReceived = false;
					damageInstigatedEventReceived = false;
					if ( witcher == GetCombatTarget() && ( witcher.IsQuenActive( true ) || witcher.IsQuenActive( false ) ) )
						return false;
					
					fxTimeCooldown = GetLocalTime() + applyFXCooldown;
					entity.PlayEffect(effectHitName);
				}
			}
		}
		
		return super.OnGameplayEvent(eventName);
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res 			: bool;
		var target 			: CNode = GetCombatTarget();
		var owner 			: CActor = GetNPC();
		var l_entity		: CEntity;
		var i 				: int;
		
		if (!foundPos)
		{
			GetEffectPositionAndRotation(pos, rot);
			foundPos = true;
		}
		
		
		l_entity = theGame.CreateEntity( effectEntityTemplate, pos, rot );
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		for ( i = 0 ; i < fxOnAnimEvent.Size() ; i += 1 )
		{
			if( animEventName == fxOnAnimEvent[i].animEvent )
			{
				l_entity.PlayEffect( fxOnAnimEvent[i].fxOnAnimEvent, target );
				return true;
			}
		}
		return false;
	}
}

class CBTTaskMagicMeleeAttackDef extends CBTTaskMagicAttackDef
{
	default instanceClass = 'CBTTaskMagicMeleeAttack';
	
	editable inlined var resourceName	 	: CBehTreeValCName;
	editable var fxOnAnimEvent 				: array<SFxOnAnimEvent>;
}

class CBTTaskMagicRangeAttack extends CBTTaskMagicAttack
{
	
	function PerformMagicAttack()
	{
		var component : CComponent;
		var target : CNode;
		
		
		target = GetCombatTarget();
		if ( !target )
		{
			target = GetActionTarget();
		}
		else
		{
			component = ((CActor)target).GetComponent('torso3effect');
		}
		
		if ( component )
		{
			GetActor().PlayEffect( effectName, component );
		}
		else if ( target )
		{
			GetActor().PlayEffect( effectName, target );
		}
		
		GetActor().OnCollisionFromItem( (CActor)target );
	}
	
	function NewCurrentAttackData( attackData : CPreAttackEventData )
	{
	}
}

class CBTTaskMagicRangeAttackDef extends CBTTaskMagicAttackDef
{
	default instanceClass = 'CBTTaskMagicRangeAttack';
}


class CBTTaskMagicFXAttack extends CBTTaskMagicAttack
{
	public var resourceName : name;
	
	private var effectEntityTemplate : CEntityTemplate;
	
	private var dealDmgOnDeactivate : bool;
	
	private var couldntLoadResource : bool;
	
	function IsAvailable() : bool
	{
		return !couldntLoadResource;
	}
	
	latent function Main() : EBTNodeStatus
	{
		effectEntityTemplate = (CEntityTemplate)LoadResourceAsync(resourceName);
		
		if ( !effectEntityTemplate )
		{
			couldntLoadResource = true;
			return BTNS_Failed;
		}
		
		super.Main();
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( dealDmgOnDeactivate )
		{
			GetActor().OnCollisionFromItem( GetCombatTarget() );
			dealDmgOnDeactivate = false;
		}
		
		super.OnDeactivate();
	}
	
	function PerformMagicAttack()
	{
		dealDmgOnDeactivate = false;
		GetActor().OnCollisionFromItem( GetCombatTarget() );
	}
	
	function NewCurrentAttackData( attackData : CPreAttackEventData )
	{
		SpawnEffect(attackData);
		dealDmgOnDeactivate = true;
	}
	
	function SpawnEffect( attackData : CPreAttackEventData ) : bool
	{
		var entity 		: CEntity;
		var pos			: Vector;
		var rot			: EulerAngles;
		
		if( effectName )
		{
			GetEffectPositionAndRotation(pos, rot);
			
			entity = theGame.CreateEntity( effectEntityTemplate, pos, rot );
			
			if ( entity )
			{
				entity.PlayEffect(effectName);
				entity.DestroyAfter(5.f);
				return true;
			}
		}
		return false;
	}
	
	function GetEffectPositionAndRotation( out pos : Vector, out rot : EulerAngles )
	{
		var target 	: CActor = GetCombatTarget();
		var owner 	: CActor = GetNPC();
		
		pos = target.GetWorldPosition();
		pos.Z += 0.7;
		rot = owner.GetWorldRotation();
	}
}

class CBTTaskMagicFXAttackDef extends CBTTaskMagicAttackDef
{
	default instanceClass = 'CBTTaskMagicFXAttack';

	editable var resourceName	 	: name;
}

class CBTTaskMagicBomb extends CBTTaskAttack
{
	var resourceName : name;
	var targetPos : Vector;
	var targetRot : EulerAngles;
	var entity : CEntity;
	var entityTemplate : CEntityTemplate;
	
	latent function Main() : EBTNodeStatus
	{
		entityTemplate = (CEntityTemplate)LoadResourceAsync( resourceName );
		
		if ( !entityTemplate )
		{
			return BTNS_Failed;
		}
		
		super.Main();
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType, animInfo);
		
		if( animEventName == 'PerformMagicAttack' )
		{
			if( useCombatTarget )
			{
				targetPos = GetCombatTarget().GetWorldPosition();
				targetRot = GetCombatTarget().GetWorldRotation();
			}
			else
			{
				targetPos = GetActionTarget().GetWorldPosition();
				targetRot = GetActionTarget().GetWorldRotation();
			}
			
			entity = theGame.CreateEntity( entityTemplate, targetPos, targetRot );
			
			return true;
		}
		
		return res;
	}	
}

class CBTTaskMagicBombDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskMagicBomb';

	editable var resourceName : name;
	
	default resourceName = 'magicBomb';
}
