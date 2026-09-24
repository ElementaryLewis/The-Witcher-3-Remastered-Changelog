/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCheckAttitudes extends IBehTreeTask
{
	public var onlyHelpActorsFromTheSameAttidueGroup 	: bool;
	public var useReactionTarget 						: bool;

	var owner 						: CActor;
	var sender 						: CActor;
	var sendersTarget				: CActor;
	var attitudeToSender			: EAIAttitude;
	var attitudeToSendersTarget		: EAIAttitude;
	var senderAttitudeGroup			: name;
	var sendersTargetAttitudeGroup	: name;
	var ownerAttitudeGroup			: name;
	
	
	private var actorToChangeAttitude : CActor;
	
	protected var reactionDataStorage 	: CAIStorageReactionData;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC;
		var ownerNPC : CNewNPC;
		owner = GetActor();
		
		if ( useReactionTarget )
			sender = (CActor)GetNamedTarget('ReactionTarget');
		else
			sender = (CActor)GetActionTarget();
		
		sendersTarget = sender.GetTarget();
		
		if ( !sender || !sender.IsAlive() || !sendersTarget || !sendersTarget.IsAlive() )
			return false;
		
		
		if ( sender.GetAttitude( sendersTarget ) != AIA_Hostile )
			return false;
		
		attitudeToSender = owner.GetAttitude( sender );
		attitudeToSendersTarget = owner.GetAttitude( sendersTarget );
		
		if ( owner.HasBuff(EET_AxiiGuardMe) )
		{
			if ( sender == thePlayer )
			{
				actorToChangeAttitude = sendersTarget;
				return true;
			}
			
			return false;
		}
		
		if ( attitudeToSender == AIA_Friendly && attitudeToSendersTarget == AIA_Friendly )
		{
			return false;
		}
		
		ownerAttitudeGroup = owner.GetAttitudeGroup();
		senderAttitudeGroup = sender.GetAttitudeGroup();
		sendersTargetAttitudeGroup = sendersTarget.GetAttitudeGroup();
		
		ownerNPC = GetNPC();
		
		if ( ownerNPC && ownerNPC.GetNPCType() == ENGT_Guard )
		{
			npc = (CNewNPC)sendersTarget;
			
			if ( npc && sender == thePlayer && attitudeToSendersTarget != AIA_Friendly )
			{
				actorToChangeAttitude = sendersTarget;
				if ( actorToChangeAttitude == thePlayer )
					return true; 
				return true;
			}
			
			npc = (CNewNPC)sender;
			
			if ( npc && sendersTarget == thePlayer &&  attitudeToSender != AIA_Friendly  )
			{	
				actorToChangeAttitude = sender;
				if ( actorToChangeAttitude == thePlayer )
					return true; 
				return true;
			}
		}
		
		if( attitudeToSendersTarget == AIA_Friendly && senderAttitudeGroup != ownerAttitudeGroup && sendersTargetAttitudeGroup == ownerAttitudeGroup )
		{
			actorToChangeAttitude = sender;
			if ( actorToChangeAttitude == thePlayer )
					return true; 
			return true;
		}
		else if( attitudeToSender == AIA_Friendly && sendersTargetAttitudeGroup != ownerAttitudeGroup && senderAttitudeGroup == ownerAttitudeGroup)
		{
			actorToChangeAttitude = sendersTarget;
			if ( actorToChangeAttitude == thePlayer )
					return true; 
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CActor = GetActor();
		
		InitializeReactionDataStorage();
		reactionDataStorage.NewTempHostileActor( owner, actorToChangeAttitude );
		
		return BTNS_Active;
	}
	
	function OnCompletion( success : bool )
	{
		reactionDataStorage.ResetAttitudes(GetActor());
	}
	
	function InitializeReactionDataStorage()
	{
		if ( !reactionDataStorage )
		{
			reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
		}
	}
}

class CBTTaskCheckAttitudesDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskCheckAttitudes';

	editable var useReactionTarget : bool;
}


class CBTTaskCheckAttitudeToTarget extends IBehTreeTask
{	
	public var attitude	: EAIAttitude;
	
	function IsAvailable() : bool
	{
		var owner 	: CActor;
		var sender 	: CActor;
		var cAtt	: EAIAttitude;
		
		owner 	= GetActor();
		sender 	= (CActor)GetActionTarget();
		cAtt 	= GetAttitudeBetween( owner, sender );
		
		return ( cAtt == attitude );
	}
}

class CBTTaskCheckAttitudeToTargetDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskCheckAttitudeToTarget';
	
	editable var attitude	: EAIAttitude;
}