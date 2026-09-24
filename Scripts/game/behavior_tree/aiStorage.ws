/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CHorseRiderSharedParams extends IScriptable
{
	import private var 	horse 		: CActor;
	import var 	mountStatus 		: EVehicleMountStatus;
	import var 	rider				: CActor;
	import var  boat 				: EntityHandle;
	import var vehicleSlot			: EVehicleSlot;
	
	
	var hasFallenFromHorse 		: bool;
	var scriptedActionPending 	: bool;
	var isPlayingAnimWithRider  : bool;
	
	var combatTarget			: CActor;
	
	default vehicleSlot				= EVS_driver_slot;
	default hasFallenFromHorse 		= false;
	default scriptedActionPending 	= false;
	default isPlayingAnimWithRider 	= false;
	
	function GetHorse() : CActor
	{
		return horse;
	}
};



import class CAIStorageAnimalData extends IScriptable
{
	var scared			: Bool; 
	default scared 		= false;	
};



import class CAIStorageHorseData extends IScriptable
{
	var horseEntity 	: CActor;
	var horseComponent 	: W3HorseComponent;
};



import class CAIStorageRiderData extends IScriptable
{
	import var sharedParams 					: CHorseRiderSharedParams;
	import var horseScriptedActionTree 			: IAIActionTree;
	
	import private var ridingManagerCurrentTask : ERidingManagerTask;
	import var ridingManagerMountError 			: bool;
	import var ridingManagerDismountType		: EDismountType;
	import var ridingManagerInstantMount		: Bool;
	
	import function PairWithTaggedHorse( actor : CActor, preferedHorseTag : name, range : Float ) : bool;
	import function OnInstantDismount( riderActor : CActor );
	function GetRidingManagerCurrentTask() : ERidingManagerTask 
	{
		return ridingManagerCurrentTask;
	}
};





class CAIStorageReactionData extends IScriptable
{
	private const var TAUNTS_TO_BE_ALARMED 	: int; default TAUNTS_TO_BE_ALARMED = 2;
	
	
	private var alarmedTimeStamp 	: float;
	
	
	function IsAlarmed( timeStamp : float ) : bool
	{
		if ( alarmedTimeStamp <= 0 || timeStamp + 7 < alarmedTimeStamp )
		{
			alarmedTimeStamp = 0.f;
			return false;
		}
		return true; 
	}
	
	function IsAngry( timeStamp : float ) : bool
	{
		return IsAlarmed(timeStamp) && tauntCounter > 0;
	}
	
	function SetAlarmed( timeStamp : float )
	{
		alarmedTimeStamp = timeStamp;
	}
	
	private var tauntCounter : int;
	private var lastTauntTimeStamp : float;
	
	function IncreaseTauntCounter( timeStamp : float, owner : CNewNPC )
	{
		if ( lastTauntTimeStamp <= 0 || timeStamp + 7 < lastTauntTimeStamp )
		{
			tauntCounter = 0;
		}
		
		tauntCounter += 1;
		lastTauntTimeStamp = timeStamp;
		
		if ( owner.GetNPCType() == ENGT_Commoner )
		{
			if ( tauntCounter >= 1 && !IsAlarmed(timeStamp) )
			{
				alarmedTimeStamp = timeStamp;
				tauntCounter = 0;
			}
		}
		else
		{
			if ( tauntCounter >= TAUNTS_TO_BE_ALARMED && !IsAlarmed(timeStamp) )
			{
				alarmedTimeStamp = timeStamp;
				tauntCounter = 0;
			}
		}
		
	}
	
	function Reset()
	{
		alarmedTimeStamp = 0.f;
		lastTauntTimeStamp = 0.f;
		tauntCounter = 0;
	}
	
	
	
	private var temporaryHostileActors : array<CActor>;
	
	public function ChangeAttitudeIfNeeded( owner : CNewNPC, _actor : CActor )
	{
		var currentAttitude : EAIAttitude;
		var npcType : ENPCGroupType;
		
		if ( !_actor )
			return;
		
		npcType = owner.GetNPCType();
		
		if ( npcType == ENGT_Commoner || npcType == ENGT_Quest )
			return;
		
		if ( _actor == thePlayer && thePlayer.IsInCombat() )
			return;
		
		if ( _actor.HasBuff(EET_AxiiGuardMe) || owner.HasBuff(EET_AxiiGuardMe) )
			return;
		
		currentAttitude = GetAttitudeBetween( owner, _actor );
		
		if ( currentAttitude != AIA_Neutral )
			return;
		
		NewTempHostileActor( owner, _actor );
	}
	
	public function NewTempHostileActor( owner : CActor, _actor : CActor )
	{
		var ownerHorse : CActor;
		
		
		if ( temporaryHostileActors.Contains(_actor) )
			return;
		
		owner.SetAttitude( _actor, AIA_Hostile );
		owner.SignalGameplayEvent( 'AI_RequestCombatEvaluation' );
		
		ownerHorse = (CActor)(owner.GetUsedHorseComponent().GetEntity());
		if ( ownerHorse )
		{
			ownerHorse.SetAttitude( _actor, AIA_Hostile );
			ownerHorse.SignalGameplayEvent( 'AI_RequestCombatEvaluation' );
		}
		
		temporaryHostileActors.PushBack(_actor);
	}
	
	public function ResetAttitudes( owner : CActor )
	{
		var i : int;
		var ownerHorse : CActor;
		
		ownerHorse = (CActor)(owner.GetUsedHorseComponent().GetEntity());
		
		for ( i=0 ; i<temporaryHostileActors.Size() ; i+=1 )
		{
			owner.ResetAttitude(temporaryHostileActors[i]);
			if ( ownerHorse )
			{
				ownerHorse.ResetAttitude( temporaryHostileActors[i] );
			}
		}
		
		temporaryHostileActors.Clear();
	}
	
	
	
	
};
