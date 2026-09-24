/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskPlayEffect extends IBehTreeTask
{
	public var effectName 				: CName;
	public var sfxInsteadOfVfx 			: bool;
	public var owner 					: CNewNPC;
	public var onTarget 				: bool;
	public var onActionTarget 			: bool;
	public var onWeaponItem 	 		: bool;
	public var turnOff 					: bool;
	public var connectEffectWithTarget 	: bool;
	public var connectWithActionTarget 	: bool;
	public var playEffectOnComponent 	: bool;
	public var componentName		 	: name;
	public var onAnimEvent				: name;
	public var onGameplayEvent			: name;
	public var bothGameplayAndAnimEvent	: bool;
	public var onInitialize 			: bool;
	public var onActivate 				: bool;
	public var onDeactivate 			: bool;
	public var onSuccess 				: bool;
	public var onFailure 				: bool;
	public var delayEffect 				: float;
	public var checkIfEffectIsPlaying	: bool;
	public var cameraShakeStrength 		: float;
	
	public var onTaggedEntity 			: bool;
	public var tagToFind				: name;
	
	
	private var animEventReceived 		: bool;
	private var gameplayEventReceived 	: bool;
	
	
	function Initialize()
	{
		if ( onInitialize )
		{
			ProcessEffect();
		}
	}
	
	function OnActivate() : EBTNodeStatus
	{
		animEventReceived = false;
		gameplayEventReceived = false;
		
		if ( onActivate )
		{
			ProcessEffect();
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var res : bool;
		
		if ( bothGameplayAndAnimEvent )
		{
			while ( !res )
			{
				if ( animEventReceived && gameplayEventReceived )
				{
					if ( delayEffect > 0 )
					{
						Sleep( delayEffect );
					}
					ProcessEffect();
					res = true;
				}
				
				SleepOneFrame();
			}
		}
		
		return BTNS_Active;
	}
	
	function OnCompletion( success : bool )
	{
		if( success && onSuccess )
		{
			ProcessEffect();
		}
		if ( !success && onFailure )
		{
			ProcessEffect();
		}
	}
	
	function OnDeactivate()
	{
		animEventReceived = false;
		gameplayEventReceived = false;
		
		if ( onDeactivate )
		{
			ProcessEffect();
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( IsNameValid( onAnimEvent ) && animEventName == onAnimEvent )
		{
			animEventReceived = true;
			if ( !bothGameplayAndAnimEvent )
			{
				ProcessEffect();
			}
			return true;
		}
		return false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( onGameplayEvent ) && eventName == onGameplayEvent )
		{
			gameplayEventReceived = true;
			if ( !bothGameplayAndAnimEvent )
			{
				ProcessEffect();
			}
			return true;
		}
		return false;
	}
	
	function ProcessEffect()
	{
		var itemIds 	: array<SItemUniqueId>;
		var inv 		: CInventoryComponent;
		var actor 		: CActor;
		var component 	: CComponent;
		var i 			: int;
		
		owner = GetNPC();
		
		if ( onTaggedEntity )
		{
			if ( sfxInsteadOfVfx )
			{
				theGame.GetEntityByTag( tagToFind ).SoundEvent( effectName );
			}
			else
			{
				theGame.GetEntityByTag( tagToFind ).PlayEffect( effectName );
			}
		}  
		if ( onTarget )
		{
			actor = GetCombatTarget();
		}
		else if ( onActionTarget )
		{
			actor = (CActor)GetActionTarget();
		}
		else
		{
			actor = owner;
		}
		
		if ( cameraShakeStrength > 0 )
		{
			GCameraShake( cameraShakeStrength, true, actor.GetWorldPosition(), 30.0f );
		}
		
		if ( IsNameValid( effectName ) )
		{
			if ( onWeaponItem )
			{
				inv = owner.GetInventory();
				itemIds = inv.GetAllWeapons();
				
				for(i=0; i<itemIds.Size(); i+=1)
				{
					if ( turnOff )
					{
						if(inv.IsItemHeld(itemIds[i]))
							inv.StopItemEffect( itemIds[i], effectName );
					}
					else
					{
						if(inv.IsItemHeld(itemIds[i]))
							inv.PlayItemEffect( itemIds[i], effectName );
					}
				}
			}
			else
			{
				if ( turnOff )
				{
					actor.StopEffect ( effectName ) ;
				}
				else if ( connectEffectWithTarget )
				{
					if ( sfxInsteadOfVfx )
					{
						actor.SoundEvent( effectName );
					}
					else
					{
						if ( connectWithActionTarget )
						{
							if ( playEffectOnComponent )
							{
								component = ( (CEntity) GetActionTarget() ).GetComponent( componentName );
								actor.PlayEffect ( effectName, component );
							}
							else
							{
								actor.PlayEffect ( effectName, GetActionTarget() );
							}
						}
						else
						{
							if ( playEffectOnComponent )
							{
								component = GetCombatTarget().GetComponent( componentName );
								actor.PlayEffect ( effectName, component );
							}
							else
							{
								actor.PlayEffect ( effectName, GetCombatTarget() );
							}
						}
					}
				}
				else
				{
					if( checkIfEffectIsPlaying )
					{
						actor.PlayEffectSingle ( effectName ) ;
					}
					else
					{
						if ( sfxInsteadOfVfx )
						{
							actor.SoundEvent( effectName );
						}
						else
						{
							actor.PlayEffect( effectName );
						}
					}
				}
			}
		}
	}
}
class CBTTaskPlayEffectDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskPlayEffect';

	editable var effectName 				: CBehTreeValCName;
	editable var sfxInsteadOfVfx 			: bool;
	editable var onWeaponItem 				: bool;
	editable var turnOff 					: bool;
	editable var onTarget 					: bool;
	editable var onActionTarget				: bool;
	editable var connectEffectWithTarget 	: bool;
	editable var connectWithActionTarget 	: bool;
	editable var playEffectOnComponent 		: bool;
	editable var componentName		 		: name;
	editable var onAnimEvent				: name;
	editable var onGameplayEvent			: name;
	editable var bothGameplayAndAnimEvent 	: bool;
	editable var onInitialize 				: bool;
	editable var onActivate 				: bool;
	editable var onDeactivate 				: bool;
	editable var onSuccess 					: bool;
	editable var onFailure 					: bool;
	editable var delayEffect 				: float;
	editable var checkIfEffectIsPlaying 	: bool;
	editable var cameraShakeStrength 		: float;
	editable var onTaggedEntity 			: bool;
	editable var tagToFind					: name;
	
	hint effectName = "Type valid name of the effect here.";
	hint turnOff = "Disables the effect instead of defaulting to turning the effect on.";
}