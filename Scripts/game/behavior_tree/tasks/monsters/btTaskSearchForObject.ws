/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSearchForObject extends IBehTreeTask
{
	public var range 							: float;
	public var tag 								: name;
	public var selectRandomObject 				: bool;
	public var avoidSelectingPreviousOne 		: bool;
	public var dontSelectClosestOneIfPossible 	: bool;
	public var addFactOnLastObject 				: bool;
	public var setActionTargetOnIsAvailable 	: bool;
	public var cooldown							: float;
	
	private var selectedObject 					: CNode;
	private var previouslySelectedObject 		: CGameplayEntity;
	private var searchTimeStamp					: float;
	
	function IsAvailable() : bool
	{
		if ( isActive ) 
			return true;
			
		if ( cooldown > 0 && searchTimeStamp > 0 && searchTimeStamp + cooldown > GetLocalTime() )
			return false;
			
		
		if ( setActionTargetOnIsAvailable )
		{
			if ( Search() )
			{
				SetActionTarget(selectedObject);
				return true;
			}
			return false;
		}
		
		return Search();
	}
	
	final function Search() : bool
	{
		var npc				: CNewNPC = GetNPC();
		var foundObjects	: array<CGameplayEntity>;
		var indeks			: int;
		
		if ( selectRandomObject )
			FindGameplayEntitiesInRange(foundObjects, npc , range, 99, tag );
		else
			FindGameplayEntitiesInRange(foundObjects, npc , range, 1, tag );
		
		FilterOutObjects(foundObjects);
		
		searchTimeStamp = GetLocalTime();
		
		if ( foundObjects.Size() > 0 )
		{
			if ( selectRandomObject )
			{
				if ( foundObjects.Size() > 1 )
				{
					if ( dontSelectClosestOneIfPossible )
						foundObjects.Erase(0);
					if ( avoidSelectingPreviousOne && previouslySelectedObject )
						foundObjects.Remove(previouslySelectedObject);
				}
				else if ( addFactOnLastObject )
				{
					FactsAdd( "last_object_" + tag, 1, -1 );
				}
				indeks = RandRange(foundObjects.Size(), 0);
				selectedObject = (CNode)foundObjects[ indeks ];
			}
			else
				selectedObject = (CNode)foundObjects[0];
				
			if (selectedObject)
			{
				return true;
			}
			return false;
		}
		else
		{
			return false;
		}
	}
	
	function FilterOutObjects( out foundObjects : array<CGameplayEntity> )
	{
		
	}

	
	function OnActivate() : EBTNodeStatus
	{
		if ( !selectedObject )
			Search();
		
		if ( !selectedObject )
			return BTNS_Failed;
		
		this.SetActionTarget(selectedObject);
		previouslySelectedObject = (CGameplayEntity)selectedObject;
		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		
		selectedObject = NULL;
	}
}

class CBTTaskSearchForObjectDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSearchForObject';

	editable var range 							: float;
	editable var tag 							: CBehTreeValCName;
	editable var selectRandomObject 			: bool;
	editable var avoidSelectingPreviousOne 		: bool;
	editable var dontSelectClosestOneIfPossible : bool;
	editable var addFactOnLastObject 			: bool;
	editable var setActionTargetOnIsAvailable 	: bool;
	editable var cooldown 						: float;
	
	default range 							= 4;
	default selectRandomObject 				= false;
	default avoidSelectingPreviousOne 		= false;
	default dontSelectClosestOneIfPossible 	= false;
	default addFactOnLastObject 			= false;
	default cooldown						= -1.f;
	
	hint selectRandomObject = "by default it selects closest object";
}


class CBTTaskSearchForOilBarrel extends CBTTaskSearchForObject
{
	final function FilterOutObjects( out foundObjects : array<CGameplayEntity> )
	{
		var i 		: int;
		var barrel 	: COilBarrelEntity;
		
		for ( i=foundObjects.Size()-1 ; i >= 0; i-=1 )
		{
			barrel = (COilBarrelEntity)foundObjects[i];
			if ( !barrel )
				foundObjects.EraseFast(i);
		}
	}
}

class CBTTaskSearchForOilBarrelDef extends CBTTaskSearchForObjectDef
{
	default instanceClass = 'CBTTaskSearchForOilBarrel';
}



class CBTTaskSearchForRift extends IBehTreeTask
{
	private var selectedObject : CNode;
	
	public var range 						: float;
	public var searchOnlyForActiveRifts 	: bool;
	
	
	function IsAvailable() : bool
	{
		return Search();
	}
	
	function Search() : bool
	{
		var i : int;
		var foundObjects : array<CGameplayEntity>;
		var riftObject : CRiftEntity;
		
		FindGameplayEntitiesInRange(foundObjects, GetActor(), range, 99,);
		
		for ( i=0; i < foundObjects.Size() ; i+=1 )
		{
			riftObject = (CRiftEntity)foundObjects[i];
			if ( riftObject && ( !searchOnlyForActiveRifts || riftObject.IsRiftOpen() ) )
			{
				selectedObject = foundObjects[i];
				return true;
			}
		}
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !selectedObject )
		{
			Search();
		}
		SetActionTarget(selectedObject);
		
		return BTNS_Active;
	}
	
}

class CBTTaskSearchForRiftDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSearchForRift';

	editable var range : float;
	editable var searchOnlyForActiveRifts : bool;
	
	default range = 20;
	default searchOnlyForActiveRifts = true;
}

