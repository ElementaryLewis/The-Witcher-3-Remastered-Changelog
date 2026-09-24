/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSetAttitude extends IBehTreeTask
{
	public var towardsActionTarget : bool;
	public var attitude : EAIAttitude;
	
	private var currentAttitude : EAIAttitude;
	private var sender 			: CActor;
	
	private var petard			: W3Petard;
	
	protected var reactionDataStorage 	: CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		if ( towardsActionTarget || !sender )
			sender = (CActor)GetActionTarget();
		
		if( !sender || sender == GetActor() )
		{
			petard = (W3Petard)GetActionTarget();
			if ( petard )
			{
				sender = (CActor)(petard.GetOwner());
				if ( !sender )
					return false;
			}
			else
				return false;
		}
		
		
		currentAttitude = GetAttitudeBetween( GetActor(), sender );
		
		if ( attitude == AIA_Hostile && currentAttitude == AIA_Friendly )
			return false;
		
		
		if ( sender == thePlayer )
			return true;
		
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var owner 			: CActor = GetActor();
		var ownerHorse 		: CActor;
		
		currentAttitude = GetAttitudeBetween( GetActor(), sender );
		
		if ( attitude == AIA_Hostile && currentAttitude == AIA_Friendly )
			return BTNS_Active;
		
		InitializeReactionDataStorage();
		
		if ( attitude == AIA_Hostile )
		{
			reactionDataStorage.NewTempHostileActor( owner, sender );
		}
		else
		{
			owner.SetAttitude( sender, attitude );
			owner.SignalGameplayEvent( 'AI_RequestCombatEvaluation' );
			
			ownerHorse = (CActor)(owner.GetUsedHorseComponent().GetEntity());
			if ( ownerHorse )
			{
				ownerHorse.SetAttitude( sender, attitude );
				ownerHorse.SignalGameplayEvent( 'AI_RequestCombatEvaluation' );
			}
		}
		
		return BTNS_Active;			
	}
	
	function OnCompletion( success : bool )
	{
		reactionDataStorage.ResetAttitudes(GetActor());
	}
	
	function OnListenedGameplayEvent( eventName : CName ) : bool
	{
		var tempSender : CActor;
		
		if ( !towardsActionTarget )
		{
			tempSender = (CActor)GetEventParamObject();
			if ( tempSender )
				sender = tempSender;
			return true;
		}
			
		return false;
	}
	
	function InitializeReactionDataStorage()
	{
		if ( !reactionDataStorage )
		{
			reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
		}
	}
}

class CBTTaskSetAttitudeDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetAttitude';

	editable var towardsActionTarget : bool;
	editable var gameplayEventName : CBehTreeValCName;
	editable var attitude : EAIAttitude;
	
	default attitude = AIA_Hostile;
	default towardsActionTarget = true;
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var task : CBTTaskSetAttitude;
		var eventName : name;
		task = (CBTTaskSetAttitude) taskGen;
		eventName = GetValCName( gameplayEventName );
		if ( IsNameValid( eventName ) )
		{
			ListenToGameplayEvent( eventName );
		}
	}
}

