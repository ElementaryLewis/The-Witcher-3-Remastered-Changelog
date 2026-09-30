/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class W3LockableEntity extends CGameplayEntity
{	
	protected editable saved var keyItemName 		: name;			
	protected editable saved var removeKeyOnUse 	: bool;			
	protected editable var alwaysEnabled				: bool;			
	private editable var enabledByFact 				: string;		
	private editable var factOnInteractionActivated	: string;		
	private editable var factOnLockedAttempt 		: string;		
	private editable var factOnUnlockedByKey 		: string;

	import protected editable var isEnabledOnSpawn 	: bool;
	import editable saved var lockedByKey : bool;							
	
	protected optional autobind mainInteractionComponent : CDoorComponent = single;
	
	protected saved var isEnabled : bool;	
	protected var isPlayerInActivationRange : bool;
	protected var isInteractionBlocked : bool;								
	
	hint alwaysEnabled = "If true then the entity will always be enabled";
	hint enabledByFact = "If set then container will not be usable if fact does not exist";
	hint factOnLockedAttempt = "Fact added when we try to use interaction on entity locked by key or fact when we don't have the key or fact does not exist";
	
	default lockedByKey 			= false;
	default removeKeyOnUse 			= true;
	default isEnabledOnSpawn 		= true;
	default isInteractionBlocked 	= false;
	default factOnUnlockedByKey 	= "";
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{
		super.OnSpawned(spawnData);
		
		
		if(!spawnData.restored)
		{
			
			if(StrLen(enabledByFact) > 0)
				isEnabled = FactsDoesExist(enabledByFact);
			else
				isEnabled = isEnabledOnSpawn;
		}
						
		Enable(isEnabled);
		CheckLock();
	}
	
	
	public function UpdateComponents(newActiveComponentName : string)
	{
		var component : CComponent;
		var statee : bool;
		
		
		component = GetComponent("Locked");
		if(component)
		{
			statee = (newActiveComponentName == "Locked");
			component.SetEnabled(statee);
		}
		else if( lockedByKey )
		{
			LogAssert(false, "W3LockableEntity.UpdateInteractionComponents: Entity <<" + this + ">> is locked but has no Locked interaction component!");
			LogLockable("W3LockableEntity.UpdateInteractionComponents: Entity <<" + this + ">> is locked but has no Locked interaction component!");
		}
		
		
		component = GetComponent("Unlock");
		if(component)
		{
			statee = (newActiveComponentName == "Unlock");
			component.SetEnabled(statee);
		}
		
		
		
		statee = ( newActiveComponentName == "Main" );

		OnStateChange( statee );
	}
	
	event OnStateChange( newState : bool )
	{
		if( mainInteractionComponent )
		{
			mainInteractionComponent.SetEnabled( newState );
		}
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if ( activator != thePlayer || isInteractionBlocked)
			return false;
					
		
		if(lockedByKey)
		{
			if( !IsNameValid(keyItemName) )
			{
				GetWitcherPlayer().DisplayHudMessage("panel_hud_message_just_locked"); 
				
				if ( factOnLockedAttempt != "" )
				{
					FactsAdd(factOnLockedAttempt, 1, 1);
				}
				return true;
			}
			
			if(!thePlayer.inv.HasItem(keyItemName))
			{
				GetWitcherPlayer().DisplayHudMessage("panel_hud_message_locked"); 
				
				if ( factOnLockedAttempt != "" )
				{
					FactsAdd(factOnLockedAttempt, 1, 1);
				}
				return true;
			} 
			else
			{	
				if( factOnUnlockedByKey != "" )
				{
					FactsAdd(factOnUnlockedByKey, 1 );
				}
				GetWitcherPlayer().DisplayHudMessage("panel_hud_message_unlock"); 
				Unlock();
				return true;
			}
		}
		
		return false;
	}
	
	public function IsLocked() : bool
	{
		return lockedByKey;
	}
	
	public function ToggleLock()
	{
		if ( IsLocked() )
		{
			Unlock();
		}
		else
		{
			Lock( 'anykey' );
		}
	}
		
	public function Unlock()
	{		
		if( IsNameValid(keyItemName) && removeKeyOnUse )
		{
			thePlayer.inv.RemoveItemByName( keyItemName, 1 );
		}
		UpdateComponents("Main");
		lockedByKey = false;
		
		PlayUnlockAudio();
	}
	
	private function PlayUnlockAudio()
	{
		if( (W3Door)this || (W3NewDoor)this )
		{
			SoundEvent( "global_doors_wooden_unlock" );
		}
	}
	
	public function Lock(keyName : name, optional removeKey : bool, optional smoooth : bool)
	{		
		var mainAsDoors : CDoorComponent;
		mainAsDoors = ( CDoorComponent ) GetComponentByClassName( 'CDoorComponent' );
		
		if( mainAsDoors )
		{
			if( smoooth )
			{
				mainAsDoors.Close( true );
			}
			else
			{
				mainAsDoors.InstantClose();
			}
		}
		OnLock();
		
		removeKeyOnUse = removeKey;
		lockedByKey = true;
		keyItemName = keyName;
		UpdateComponents("Locked");
	}
	
	protected function OnLock()
	{
	}
	
	protected function CheckLock()
	{
		if( lockedByKey )
		{
			Lock( keyItemName, removeKeyOnUse );
		}
	}
	
	public function Enable(e : bool, optional skipInteractionUpdate : bool, optional questForcedEnable : bool)
	{
		isEnabled = e || alwaysEnabled;
		if(isEnabled)
		{
			if( lockedByKey )
			{
				if( mainInteractionComponent )
				{
					mainInteractionComponent.InstantClose();
				}
				UpdateComponents("Locked");
			}
			else
			{
				UpdateComponents("Main");	
			}
		}
		else
			UpdateComponents("");
			
		if(isPlayerInActivationRange && !skipInteractionUpdate)
			ShowInteractionComponent();	
	}
	
	
	public function ShowInteractionComponent()
	{				
		if(isEnabled)
		{
			if(lockedByKey)
			{
				if( IsNameValid(keyItemName) && thePlayer.inv.HasItem(keyItemName))
				{
					UpdateComponents("Unlock");
				}
				else
				{
					UpdateComponents("Locked");
					thePlayer.nearbyLockedContainersNoKey.PushBack(this);
				}
			}
			else
			{
				UpdateComponents("Main");
			}
		}
		else
		{
			UpdateComponents("");
		}		
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		if(activator == thePlayer)
		{
			isPlayerInActivationRange = true;
			if (StrLen(factOnInteractionActivated) > 0)
				FactsSet(factOnInteractionActivated, 1, -1);
		}
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{		
		if(activator == thePlayer)
		{
			isPlayerInActivationRange = false;
			thePlayer.nearbyLockedContainersNoKey.Remove(this);	
		}		
	}
	
	event OnAreaEnter(area : CTriggerAreaComponent, activator : CComponent)
	{
		
		if(StrLen(enabledByFact) > 0 && activator.GetEntity() == thePlayer) 
			AddTimer('RefreshFactStatus', 0.001, true, , , true);
	}
	
	event OnAreaExit(area : CTriggerAreaComponent, activator : CComponent)
	{
		if(StrLen(enabledByFact) > 0 && activator.GetEntity() == thePlayer) 
			RemoveTimer('RefreshFactStatus');
	}
		
	timer function RefreshFactStatus(dt : float, id : int)
	{
		
		if(isEnabled != FactsDoesExist(enabledByFact))
		{
			LogLockable("W3LockableEntity.RefreshFactStatus: enabling fact status is different than the enabled state of <<" + this + ">>, changing enabled state to " + (!isEnabled));
			Enable(!isEnabled);
		}
	}
	
	event OnStreamIn()
	{
		Enable(isEnabled);		
	}
	
	event OnLockForced()
	{
		Unlock();
	}
	
	public function GetKeyName() : name					{return keyItemName;}
	public function IsEnabled() : bool					{return isEnabled;}
	public function SetInteractionBlocked(b : bool)		{isInteractionBlocked = b;}
}