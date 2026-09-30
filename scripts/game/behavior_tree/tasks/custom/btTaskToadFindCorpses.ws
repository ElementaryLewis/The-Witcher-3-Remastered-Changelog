/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskToadFindCorpses extends IBehTreeTask
{
	var corpsesArray 		: array< CGameplayEntity >;
	var closestCorpse		: CGameplayEntity;
	var searchRange			: float;
	var maxResults			: int;
	var tag					: name;
	var i					: int;
	var npc					: CNewNPC;
	var tempMinDist			: float;
	var minDist				: float;
	var closestCorpsePos 	: Vector;
	
	default searchRange = 15.0;
	default maxResults = 3;
	default tag = 'q601_toad_corpse';
	
	function OnActivate() : EBTNodeStatus 
	{
		minDist = 1000.0;
		npc = GetNPC();
		corpsesArray.Clear();
		
		FindGameplayEntitiesInRange( corpsesArray, npc, searchRange, maxResults, tag );
		if( corpsesArray.Size() )
		{
			return BTNS_Active;
		}
		else
		{
			return BTNS_Failed;
		}
		
	}
	
	latent function Main() : EBTNodeStatus
	{
		for( i=0; i<corpsesArray.Size(); i+=1 )
		{
			tempMinDist = VecDistance2D( npc.GetWorldPosition(), corpsesArray[i].GetWorldPosition() );
			if( tempMinDist < minDist )
			{
				minDist = tempMinDist;
				closestCorpse = corpsesArray[i];
			}
		}
		
		SetActionTarget( closestCorpse );
		
		return BTNS_Completed;
	}
	

}
class CBTTaskToadFindCorpsesDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskToadFindCorpses';
	
	editable var searchRange		: float;
	editable var maxResults			: int;
	editable var tag				: name;

}