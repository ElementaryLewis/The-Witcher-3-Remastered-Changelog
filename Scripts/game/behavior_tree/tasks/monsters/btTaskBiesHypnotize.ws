/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskBiesHypnotize extends CBTTask3StateAttack
{
	var cameraIndex 	: int;
	var ignoreConeCheck : bool;
	var effectDuration : float;
	
	private var done : bool;
	
	default done = false;
	
	default cameraIndex = -1;
	
	latent function Loop() : int
	{
		var targets 		: array<CActor>;
		var initialTargets 	: array<CActor>;
		var endTime 		: float;
		
		endTime = GetLocalTime() + loopTime;
		
		GetActor().PlayEffect('third_eye_fx');
		GetActor().SoundEvent('monster_bies_confusion_warmup_start');
		
		if ( GetCombatTarget() == thePlayer )
		{
			GCameraShake(1, true, thePlayer.GetWorldPosition(), 30.0f);
		}
		
		GetTargets(targets);
		initialTargets = targets;
		
		while ( GetLocalTime() <= endTime )
		{
			if ( !ignoreConeCheck )
			{
				GetTargets(targets);
				
				if ( targets.Size() <= 0 )
				{
					return 0;
				}
				
				if ( isPlayerAmongTargets(targets) )
				{
					GCameraShake(0.1, true, thePlayer.GetWorldPosition(), 30.0f);
					
					Sleep(0.1);
					GCameraShake(0.1, true, thePlayer.GetWorldPosition(), 30.0f);
					
					
				}
			}
			else
			{
				if ( isPlayerAmongTargets(initialTargets) )
				{
					GCameraShake(0.1, true, thePlayer.GetWorldPosition(), 30.0f);
					
					Sleep(0.1);
					GCameraShake(0.1, true, thePlayer.GetWorldPosition(), 30.0f);
					
					
				}
			}
			
			Sleep(0.1);
		}
		
		if ( !ignoreConeCheck )
			ApplyBuff(targets);
		else
			ApplyBuff(initialTargets);
		
		done = true;
		
		GetActor().SoundEvent('monster_bies_confusion_warmup_stop');
		
		if ( !ignoreConeCheck && !GetTargets(targets) )
			return -1;
		else if ( !GetTargets(initialTargets) )
			return -1;
		
		return 0;
	}
	
	function GetTargets(out targets : array<CActor>) : bool
	{
		
		var owner : CNewNPC = GetNPC();
		
		targets = owner.GetAttackableNPCsAndPlayersInCone(20,owner.GetHeading(),120,0);
		
		if (targets.Size() > 0 )
		{
			return true;
		}
		
		return false;
	}
	
	function isPlayerAmongTargets( targets : array<CActor> ) : bool
	{
		var i : int;
		var player : CPlayer = thePlayer;
		
		for ( i=0 ; i < targets.Size() ; i +=1 )
		{
			if ( ((CPlayer)targets[i]) == player )
			{
				return true;
			}
		}
		return false;
	}
	
	function ApplyBuff( targets : array<CActor> ) 
	{
		var i : int;
		var params : SCustomEffectParams;
		
		params.effectType = EET_Hypnotized;
		params.creator = GetActor();
		params.sourceName = "bies_hypnotize";
		params.duration = effectDuration;
		
		for ( i=0 ; i < targets.Size() ; i+=1 )
		{
			if ( targets[i] )
				targets[i].AddEffectCustom(params);
		}
	}
	
	function OnDeactivate() 
	{
		var player 	: CR4Player = thePlayer;
		var res 	: bool;
		
		if ( !thePlayer.HasBuff( EET_Hypnotized ) )
			res = true;
		
		
		if ( !done || res )
		{
			GetActor().StopEffect('third_eye_fx');
			
		}
		done = false;
		res = false;
		
		super.OnDeactivate();
		
		GetActor().SoundEvent('monster_bies_confusion_warmup_stop');
		if ( cameraIndex >= 0 )
		{
			player.DisableCustomCamInStack( cameraIndex );
			cameraIndex = -1;
		}
	}
	
	
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		
		if ( eventName == 'HypnotizeAdded' )
		{
			GetActor().PlayEffect('third_eye_active');
			GetActor().SoundEvent('monster_bies_confusion_sustain_start ');
		}
		if ( eventName == 'HypnotizeRemoved' )
		{
			GetActor().StopEffect('third_eye_active');
			GetActor().SoundEvent('monster_bies_confusion_sustain_stop ');
		}
		if ( eventName == 'CameraIndex' )
		{
			cameraIndex = GetEventParamInt(-1);
		}
		return false;
	}
}

class CBTTaskBiesHypnotizeDef extends CBTTask3StateAttackDef
{
	editable var ignoreConeCheck : bool;
	editable var effectDuration : float;

	default effectDuration = 20.f;
	default instanceClass = 'CBTTaskBiesHypnotize';

	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'HypnotizeRemoved' );
	}
}