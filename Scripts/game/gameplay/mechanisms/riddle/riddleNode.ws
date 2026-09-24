/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SRiddleNodePositionDef
{
	editable var animName 			 		 : name;
	editable var changePosTime	 		 	 : float; default changePosTime = 1.f;
	editable var fxName	  			 		 : name;
	editable var pairedRiddleNodes		 	 : array <SPairedRiddleNodeDef>;
	editable var isPositionValid			 : bool;
	editable var externalRiddleFx			 : SExternalRiddleEffectEntityDef;
	editable var igni						 : bool;
	editable var aard						 : bool;
	
	
}

struct SExternalRiddleEffectEntityDef
{
	editable var  entityTag 	: name;
	editable var  fxName	    : name;
	         var isEffectOn		: bool;
}
struct SPairedRiddleNodeDef
{
	editable var pairedRiddleNodeTag 		 : name;
	editable var pairedRiddleNodeRequiredPos : int;
	editable var externalRiddleFx			 : SExternalRiddleEffectEntityDef;
}
class W3RiddleNode extends CGameplayEntity
{
	editable var positions 					: array <SRiddleNodePositionDef>;
	editable var riddleServerTag 			: name;
	editable var factOnPositionValid 		: string;
	editable var useFocusModeHelper 		: bool;
	
	saved var currentPos					: int; default currentPos = 0;
	saved var rewind						: bool;
	saved var currentPairedRiddleNodeID		: int;
	
	saved var currentPairedRiddleNodesIDS 	:array< int>;
	
	var riddleServer						: W3RiddleServer;
	saved var wasAddedToServer				: bool;
	var lastPosID							: int;
	var isDisabled							: bool;
	var isEffectOn	 						: bool;
	var isOnValidPosition					: bool;
	var initializeServerCounter				: int;
	
	
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		lastPosID = positions.Size() - 1;
		InitializeServer ();
	}
	
	event OnIgniHit( sign : W3IgniProjectile )
	{
		if ( positions[currentPos].igni && !isDisabled )
		{
			ChangePosition ();
		}
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		if ( positions[currentPos].aard && !isDisabled)
		{
			ChangePosition ();
		}
	}
	function InitializeServer ()
	{
		var i : int;
		
		if ( !riddleServer )
		{
			riddleServer = (W3RiddleServer)theGame.GetEntityByTag ( riddleServerTag );
		}
		if ( riddleServer )
		{
			if ( !wasAddedToServer )
			{
				wasAddedToServer = true;
				riddleServer.AddRiddleNode();
				
				for ( i=0; i< positions.Size (); i += 1 )
				{
					if ( positions[i].pairedRiddleNodes.Size() > 0 )
					{
						riddleServer.AddPairedRiddleNode( this );
					}
				}
				
			}
			
			
			SetPosition ();
		}
		else
		{
			AddTimer( 'InitializeServerTimer', 1.0f, true );
		}
		
	}
	
	timer function InitializeServerTimer ( timeDelta : float, id : int )
	{
		if ( riddleServer || initializeServerCounter >= 10 )
		{
			initializeServerCounter = 0;
			RemoveTimer ( 'InitializeServerTimer' );
		}
		else
		{
			InitializeServer ();
			
			initializeServerCounter += 1;
		}
	}
	
	function SetCurrentPairedRiddleNodeId ( id : int )
	{
		currentPairedRiddleNodeID = id;
	}
	
	function AddCurrentPairedRiddleNodeId ( id : int )
	{
		currentPairedRiddleNodesIDS.PushBack ( id );
	}
	
	function RemoveCurrentPairedRiddleNodeId ( id : int )
	{
		currentPairedRiddleNodesIDS.Remove ( id );
	}
	
	function SetCurrentPairedRiddleNodesIds ( ids : array<int> )
	{
		currentPairedRiddleNodesIDS = ids;
	}
	
	function PlayEffects ()
	{
		var externalFxEntity : CEntity;
		
		if ( positions[currentPos].fxName != '' )
		{
			PlayEffectSingle( positions[currentPos].fxName );
		}
		if ( positions[currentPos].externalRiddleFx.entityTag != '' && !positions[currentPos].externalRiddleFx.isEffectOn )
		{
			externalFxEntity = theGame.GetEntityByTag ( positions[currentPos].externalRiddleFx.entityTag );
			externalFxEntity.PlayEffectSingle ( positions[currentPos].externalRiddleFx.fxName );
			positions[currentPos].externalRiddleFx.isEffectOn = true;
			
		}
		isEffectOn = true;
	}
	
	function PlayExternalEffectOnpairedNodeByID ( id : int )
	{
		var externalFxEntity : CEntity;
		
		if ( positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.entityTag != '' && !positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.isEffectOn )
		{
			externalFxEntity = theGame.GetEntityByTag ( positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.entityTag );
			externalFxEntity.PlayEffectSingle ( positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.fxName );
			positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.isEffectOn = true;
			
		}
	}
	
	function StopExternalEffectOnpairedNodeByID ( id : int )
	{
		var externalFxEntity : CEntity;
		
		if ( positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.entityTag != '' && positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.isEffectOn )
		{
			externalFxEntity = theGame.GetEntityByTag ( positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.entityTag );
			externalFxEntity.StopEffect ( positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.fxName );
			positions[currentPos].pairedRiddleNodes[id].externalRiddleFx.isEffectOn = false;
		}
	}
	
	function StopEffects ()
	{
		var  i : int;
		var  pairedID : int;
		
		var externalFxEntity : CEntity;
	
		if ( positions[currentPos].fxName != '' )
		{
			StopEffect( positions[currentPos].fxName );
			
		}
		if ( positions[currentPos].externalRiddleFx.entityTag != ''  && positions[currentPos].externalRiddleFx.isEffectOn )
		{
			externalFxEntity = theGame.GetEntityByTag ( positions[currentPos].externalRiddleFx.entityTag );
			externalFxEntity.StopEffect ( positions[currentPos].externalRiddleFx.fxName );
			positions[currentPos].externalRiddleFx.isEffectOn = false;
			
		}
		for ( i=0; i< currentPairedRiddleNodesIDS.Size(); i+=1 )
		{
			pairedID = currentPairedRiddleNodesIDS[i];
			
			if ( positions[currentPos].pairedRiddleNodes[pairedID].externalRiddleFx.entityTag != '' )
			{
				externalFxEntity = theGame.GetEntityByTag ( positions[currentPos].pairedRiddleNodes[pairedID].externalRiddleFx.entityTag );
				externalFxEntity.StopEffect ( positions[currentPos].pairedRiddleNodes[pairedID].externalRiddleFx.fxName );
				positions[currentPos].pairedRiddleNodes[pairedID].externalRiddleFx.isEffectOn = false;
				
			}
		}
		isEffectOn = false;
	}
	
	public function ChangePosition ()
	{
		StopEffects ();
		
		if ( currentPos == lastPosID )
		{
			rewind = true;
		}
		if ( currentPos == 0 )
		{
			rewind = false;
		}
		
		if ( !rewind )
		{
			currentPos +=1;
			SetPosition ();
		}
		else
		{
			SetPosition ();
			currentPos -=1;
		}
		
		LogQuest("RiddleNode <<" + this.GetName() + ">> is at position <<" + currentPos + ">>");
		
	}
	
	public function SetPosition ()
	{
		if ( isDisabled )
		{
			return;
		}
		if ( !rewind )
		{
			if ( positions[currentPos].animName != '' )
			{
				isDisabled = true;
				PlayPropertyAnimation( positions[currentPos].animName, 1, positions[currentPos].changePosTime );				
			}
			AddTimer ( 'SetPositionTimer', positions[currentPos].changePosTime, false );
		}
		else
		{	
			if ( positions[currentPos].animName != '' )
			{
				isDisabled = true;
				PlayPropertyAnimation( positions[currentPos].animName, 1, positions[currentPos].changePosTime, PCM_Backward );					
			}
			AddTimer ( 'SetPositionTimer', positions[currentPos].changePosTime, false );
		}
		
	}
	
	timer function SetPositionTimer ( timeDelta : float, id : int )
	{
		
		isDisabled = false;
		
		if ( !riddleServer )
		{
			InitializeServer();
		}
		
		if ( factOnPositionValid != "" )
		{
			if ( positions[currentPos].isPositionValid )
			{
				FactsAdd ( factOnPositionValid, 1, -1 );
			}
			else if ( FactsQuerySum ( factOnPositionValid ) > 0 )
			{
				FactsAdd ( factOnPositionValid, -1, -1 );
			}
		}
		if ( positions[currentPos].isPositionValid )
		{
			if ( !isOnValidPosition )
			{	
				if ( !wasAddedToServer )
				{
					wasAddedToServer = true;
					riddleServer.AddRiddleNode();
				}
				riddleServer.AddValidPosition();
				isOnValidPosition = true;
			}
			if ( useFocusModeHelper )
			{
				SetFocusModeVisibility( FMV_Interactive );
			}
		}
		else if ( !positions[currentPos].isPositionValid )
		{
			if ( isOnValidPosition )
			{
				if ( !wasAddedToServer )
				{
					wasAddedToServer = true;
					riddleServer.AddRiddleNode();
				}
				riddleServer.RemoveValidPosition();
				isOnValidPosition = false;
			}
			if ( useFocusModeHelper )
			{
				SetFocusModeVisibility( FMV_Clue );
			}
		}
		if ( positions[currentPos].pairedRiddleNodes.Size() == 0 )
		{
			PlayEffects();
		}
		
		riddleServer. UpdatePairedRiddleNodes ();
		
	}
	
	
}