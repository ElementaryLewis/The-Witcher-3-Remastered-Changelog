/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ApplyEffectPhantomComponent extends CPhantomComponent
{
	
	
	
	editable var effectToApply			: EEffectType;
	editable var effectDuration			: float;	
	editable var requiredAbilities		: array<name>;
	editable var onlyWhenAlive			: bool;
	editable var onlyToHostiles			: bool;
	editable var onlyToTag				: name;
	editable var ignoreIfHasEffect		: bool;
	editable var useCustomValue			: bool;
	editable var customValue			: SAbilityAttributeValue;
	editable var forcedDamage			: float;
	editable var minRelativeSpeed		: float;
	editable var decreasePlayerDmgBy	: float; default decreasePlayerDmgBy = 0.f;
	editable var playFXonCollisionEnter	: CName;
	editable var stopFXonCollisionExit	: bool;
	
	
	public 	 var objectAttached			: bool;
	
	default	eventsCalledOnComponent 	= true;
	default onTriggerEnteredScriptEvent = "OnCollisionEnter";
	default onlyWhenAlive 				= true;
	default ignoreIfHasEffect			= true;
	default forcedDamage				= -1;
	default minRelativeSpeed			= -1;
	
	hint minRelativeSpeed 		= "minimum speed the actor must be moving at to apply the effect";
	
	
	hint requiredAbilities		= "Abilities required for this component to work - Leave empty and the component will always work";
	hint onlyWhenAlive			= "If the component is attached on an actor, the effect won't be applied when the actor is dead";
	hint ignoreIfHasEffect		= "Do not apply the effect if the target already has it";
	hint forcedDamage			= "Apply this damage regardless of the target being immune to the effect";
	
	hint decreasePlayerDmgBy		= "Percentage vaule. Min 0, max 1. Apply this to decrease dmg dealt to player";
	
	
	event OnCollisionEnter( object : CObject, physicalActorindex : int, shapeIndex : int )
	{
		var i					: int;
		var l_ability			: name;
		var l_actor				: CActor;
		var l_target 			: CActor;
		var l_entityTarget 		: CEntity;
		var l_source			: CGameplayEntity;
		var l_params			: SCustomEffectParams;
		var l_action			: W3DamageAction;
		var l_animatedComponent	: CAnimatedComponent;
		var l_speed				: float;
		var component			: CComponent;
		
		component = (CComponent) object;
		if( !component )
		{
			return false;
		}
		
		l_actor = (CActor) GetEntity();
		
		
		if( l_actor && onlyWhenAlive && !l_actor.IsAlive() ) return false;		
		
		if( requiredAbilities.Size() > 0 )
		{		
			if( !l_actor ) return false;
			
			for( i = 0; i < requiredAbilities.Size() ; i += 1 )
			{			
				l_ability = requiredAbilities[0];
				if(  !l_actor.HasAbility( l_ability ) || l_actor.IsAbilityBlocked( l_ability ) )
				{ 
					return false;
				}
			}
		}
		
		l_target = (CActor) component.GetEntity();
		l_entityTarget = component.GetEntity();
		
		if( !l_target ) return false;
		if( l_target == l_actor ) return false;
		
		
		if( onlyToHostiles && l_actor && l_actor.GetAttitude( l_target ) != AIA_Hostile )
		{
			return false;
		}
		
		if( IsNameValid( onlyToTag ) && !l_target.HasTag( onlyToTag ) )
		{
			return false;
		}
		
		if ( ignoreIfHasEffect && l_target.HasBuff( effectToApply ) )
		{	 
			return false;
		}
		
		if( minRelativeSpeed > 0 )
		{
			l_animatedComponent = ( CAnimatedComponent ) GetEntity().GetComponentByClassName( 'CAnimatedComponent' );
			l_speed = l_animatedComponent.GetMoveSpeedRel();
			
			if( l_speed < minRelativeSpeed )
			{
				return false;
			}
		}
		
		l_source = ( CGameplayEntity ) GetEntity();
		
		l_params.effectType = effectToApply;
		l_params.creator = l_source;
		l_params.sourceName = l_actor.GetName();
		l_params.duration = effectDuration;
		
		if( useCustomValue ) 
		{
			l_params.effectValue = customValue;
		}
		l_target.AddEffectCustom(l_params);
		
		if( forcedDamage > 0 )
		{
			l_action = new W3DamageAction in this;
			l_action.Initialize( l_source, l_target, NULL, l_source.GetName(), EHRT_None, CPS_Undefined, false, false, false, true);
			l_action.SetCanPlayHitParticle(false);
			if ( l_target == thePlayer )
			{
				forcedDamage = forcedDamage - (forcedDamage * decreasePlayerDmgBy);
			}
			l_action.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, forcedDamage );
			l_action.SetSuppressHitSounds( true );
			
			theGame.damageMgr.ProcessAction( l_action );
			
			delete l_action;
		}
		
		if( IsNameValid( playFXonCollisionEnter ) && !theGame.IsDialogOrCutscenePlaying() )
		{
			GetEntity().PlayEffectSingle( playFXonCollisionEnter );
			((CGameplayEntity) GetEntity()).AddCutsceneForbiddenFX( playFXonCollisionEnter );
		}
	}
	
	event OnCollisionExit( object : CObject, physicalActorindex : int, shapeIndex : int  )
	{
		if( stopFXonCollisionExit && IsNameValid( playFXonCollisionEnter ) )
		{
			GetEntity().StopEffect( playFXonCollisionEnter );
		}
	}
	
	public function GetClosestFreeSlotInfo( attachComponents : array<name>, _objectPosition : Vector, _objectHeading : float ,out _ClosestSlotName : name, out _Position : Vector, out _Heading : float ) : bool
	{
		var i					: int;
		var l_slotMatrix 		: Matrix;
		var l_slotPos			: Vector;
		var l_closestDistance	: float;
		var l_closestMatrix		: Matrix;
		var l_closestPos		: Vector;
		var l_distance			: float;
		var l_npcPos			: Vector;
		var l_slotRotation		: EulerAngles;
		var l_slotForward		: Vector;
		var l_slotName			: name;
		var l_angleDistance		: float;
		
		if( attachComponents.Size() == 0 ) return false;
		
		l_closestDistance = 999;
		
		for( i = 0; i < attachComponents.Size(); i += 1 )
		{
			l_slotName 	= attachComponents[i];
			GetEntity().CalcEntitySlotMatrix( l_slotName, l_slotMatrix );
			l_slotPos	= MatrixGetTranslation( l_slotMatrix );
			
			l_distance = VecDistance( _objectPosition, l_slotPos );
			if( l_distance < l_closestDistance )
			{
				l_closestDistance 	= l_distance;
				l_closestPos		= l_slotPos;
				l_closestMatrix		= l_slotMatrix;
				_ClosestSlotName 	= l_slotName;
			}
		}
		
		l_slotRotation	= MatrixGetRotation( l_closestMatrix );
		l_slotForward	= RotForward( l_slotRotation ); 
		_Heading		= VecHeading( l_slotForward );
		_Position		= l_closestPos;
		
		l_angleDistance = AngleDistance( _objectHeading, _Heading);
		
		if( AbsF( l_angleDistance ) > 50 )
		{
			return false;
		}
		
		return true;
	}
	
	public function SetObjectAttached( b : bool )
	{
		objectAttached = b;
	}
	
	public function IsObjectAttached() : bool
	{
		return objectAttached;
	}
}
