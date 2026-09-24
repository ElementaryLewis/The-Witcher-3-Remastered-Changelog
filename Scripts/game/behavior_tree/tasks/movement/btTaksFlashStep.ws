/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskFlashStep extends IBehTreeTask
{
	var vanish : bool;
	var disallowInPlayerFOV : bool;
	var teleportOutsidePlayerFOV : bool;
	var alreadyTeleported : bool;
	var teleportType : ETeleportType;
	var disappearfxName, appearFXName, emptyName : name;
	var minDistance : float;
	var maxDistance : float;
	var distFromLastTelePos : float;
	var cameraToPlayerDistance : float;
	var cooldown : float;
	var isTeleporting : bool;
	var nextTeleTime : float;
	var angle : float;
	var heading : Vector;
	var lastTelePos : Vector;
	var randVec : Vector;
	var whereTo : Vector;
	var teleportEventName : name;
	var behEventName : name;
	
	default vanish = false;
	default nextTeleTime = 0;
	default isTeleporting = false;
	default alreadyTeleported = false;
	default teleportEventName = 'Vanish';
	default emptyName = '';
	
	function IsAvailable() : bool
	{
		if ( isActive )
		{
			return true;
		}
		
		if (  nextTeleTime > 0 && nextTeleTime > GetLocalTime() )
		{
			return false;
		}
		if ( disallowInPlayerFOV )
		{
			if ( !ActorInPlayerFOV() )
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return true;
		}
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var res : bool;
		
		CalculateRandVec();
		
		if ( teleportOutsidePlayerFOV )
		{
		
		}
		else if ( teleportType == TT_ToPlayer || teleportType == TT_FromLastPosition )
		{
			whereTo = thePlayer.GetWorldPosition() - randVec;
		}
		else
		{
			whereTo = npc.GetWorldPosition() - randVec;
		}
		
		while ( !theGame.GetWorld().NavigationCircleTest( whereTo, 1 ) )
		{
			CalculateRandVec();
			Sleep( 0.000001f );
		}
		
		while ( !vanish )
		{
			Sleep( 0.1 );
		}		
		isTeleporting = true;
		
		npc.TeleportWithRotation(whereTo, VecToRotation( npc.GetTarget().GetWorldPosition() ));
		
		
			
			if( appearFXName != emptyName )
			{
				npc.PlayEffect( appearFXName );
			}
			lastTelePos = whereTo;
			nextTeleTime = GetLocalTime() + cooldown;
			alreadyTeleported = true;
			return BTNS_Completed;
		
		
		return BTNS_Failed;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetBehaviorVariable( 'teleport_on_hit', 0 );
		if ( isTeleporting )
		{
			GetNPC().ActionCancelAll();
			isTeleporting = false;
			vanish = false;
		}
	}
	
	latent function FlashStep()
	{
		var npc : CNewNPC = GetNPC();
		
		npc.DisableHitAnimFor( 1.0 );
		npc.RaiseEvent( behEventName );
		
		if( disappearfxName != emptyName )
		{
			npc.PlayEffect( disappearfxName );
		}
		
	}
	
	function ActorInPlayerFOV() : bool
	{
		var npc	: CNewNPC = GetNPC();
		
		if ( thePlayer.WasVisibleInScaledFrame( npc, 1.15f, 1.15 ) )
		{
			return true;
		}
		return false;
	}
	
	function CalculateRandVec()
	{
		var npc : CNewNPC = GetNPC();
		
		if ( teleportOutsidePlayerFOV )
		{
		
			if ( cameraToPlayerDistance*1.2 > minDistance )
			{
				minDistance = cameraToPlayerDistance*1.2;
				maxDistance = ( maxDistance + ( cameraToPlayerDistance - minDistance ))*1.2;
			}
		
		}
		else if ( teleportType == TT_FromLastPosition )
		{
			angle = NodeToNodeAngleDistance( npc.GetTarget(), npc );
			
			if ( alreadyTeleported )
			{
				distFromLastTelePos = VecDistance( lastTelePos, npc.GetWorldPosition() );
				minDistance = distFromLastTelePos - 2;
				maxDistance = distFromLastTelePos + 2;
				randVec = VecConeRand( angle, 30, minDistance, maxDistance );
			}
			else
			{
				randVec = VecRingRand(minDistance,maxDistance);
			}
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType ) : bool
	{
		if ( animEventName == teleportEventName )
		{
			vanish = true;
			return true;
		}
		return false;
	}
};

class CBTTaskFlashStepDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFlashStep';

	editable var minDistance : float;
	editable var maxDistance : float;
	editable var cooldown : float;
	editable var teleportEventName : name;
	
	editable var disallowInPlayerFOV : bool;
	editable var teleportOutsidePlayerFOV : bool;
	editable var teleportType : ETeleportType;
	editable var disappearfxName : name;
	editable var appearFXName : name;
	
	default minDistance = 3.0;
	default maxDistance = 5.0;
	default cooldown = 5.0;
	default disallowInPlayerFOV = false;
	default teleportOutsidePlayerFOV = true;
	default teleportType = TT_ToPlayer;
	default teleportEventName = 'Vanish';
};