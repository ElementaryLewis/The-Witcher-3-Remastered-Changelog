/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EChosenTarget
{
	ECT_CombatTarget,
	ECT_AlwaysPlayer,
	ECT_Self,
	ECT_SpecifiedTag
}

class CBTTaskUseInteractiveEntitiesInRange extends IBehTreeTask
{
	
	var animationEventName		: name;
	var usableEntityTag	: name;
	var maxTriggeredEntities	: int;
	var delayBetweenUses		: float;
	var checkDistance			: float;
	var minDistanceToSelf		: float;
	var targetType				: EChosenTarget;
	var targetTag				: name;
	var betweenTargetAndSelf	: bool;
	
	
	var chosenEntities 			: array<W3UsableEntity>;
	var interactiveNodes		: array<CNode>;
	var lastUsedTime			: EngineTime;
	var npc						: CNewNPC;
	
	function GatherEntities() : bool
	{
		var targetNode 			: CNode;
		var size, i, size2		: int;
		var usableEntity		: W3UsableEntity;
		var distanceToTarget	: float;
		var distanceToSelf		: float;
		var targetPosition		: Vector;
		var selfPosition		: Vector;
		var normalizedDir		: Vector;
		var distanceBetween		: float;
		
		npc = GetNPC();
		
		if( targetType == ECT_CombatTarget )
		{
			targetNode = GetCombatTarget();
		}
		else if( targetType == ECT_AlwaysPlayer )
		{
			targetNode = thePlayer;
		}
		else if( targetType == ECT_Self )
		{
			targetNode = npc;
		}
		else if( targetType == ECT_SpecifiedTag )
		{
			targetNode = theGame.GetNodeByTag( targetTag );
		}
		
		if( targetNode )
		{
			chosenEntities.Clear();
			
			targetPosition = targetNode.GetWorldPosition();
			selfPosition = npc.GetWorldPosition();
			
			distanceBetween = VecDistance(targetPosition, selfPosition);
			
			if( betweenTargetAndSelf )
			{
				normalizedDir = VecNormalize(targetPosition - selfPosition);
				targetPosition = selfPosition + 0.5*distanceBetween*normalizedDir;
			}
			
			theGame.GetNodesByTag( usableEntityTag, interactiveNodes );
			
			size = interactiveNodes.Size();
			
			for( i = 0; i < size; i += 1)
			{
				usableEntity = (W3UsableEntity)interactiveNodes[i];
				if( usableEntity && usableEntity.CanBeUsed() )
				{
					distanceToTarget = VecDistance2D( usableEntity.GetWorldPosition(),targetPosition );
					distanceToSelf = VecDistance2D( usableEntity.GetWorldPosition(), selfPosition );
					
					size2 = chosenEntities.Size();
					
					if( size2 < maxTriggeredEntities - 1 && distanceToTarget <= checkDistance && distanceToSelf >= minDistanceToSelf )
					{
						chosenEntities.PushBack( usableEntity );
					}
				}
			}
		}
		size2 = chosenEntities.Size();
			
		return size2 > 0;
	}
	
	function IsAvailable() : bool
	{
		var available : bool;
		
		available = false;
		
		if( theGame.GetEngineTime() > lastUsedTime + delayBetweenUses )
		{
			if( GatherEntities() )
			{
				available = true;
			}
		}
		
		return available;
	}
	
	function UseEntities()
	{
		var size, i : int;
		
		size = chosenEntities.Size();
		
		if( size > 0 )
		{
			lastUsedTime = theGame.GetEngineTime();
		}
		
		for( i = 0; i < size; i += 1 )
		{
			chosenEntities[i].UseEntity();
		}
	}

	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == animationEventName )
		{
			UseEntities();
			return true;
		}
		return false;
	}	
}
class CBTTaskUseInteractiveEntitiesInRangeDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskUseInteractiveEntitiesInRange';

	editable var animationEventName		: name;
	editable var usableEntityTag		: name;
	editable var maxTriggeredEntities	: int;
	editable var delayBetweenUses		: float;
	editable var checkDistance			: float;
	editable var minDistanceToSelf		: float;
	editable var targetType				: EChosenTarget;
	editable var targetTag				: name;
	editable var betweenTargetAndSelf		: bool;
	
	default animationEventName = 'UseSpawner';
	default usableEntityTag = 'i_spawner';
	default checkDistance = 10.0f;
	default delayBetweenUses = 10.0f;
	default maxTriggeredEntities = 3;
	default minDistanceToSelf = 10.0f;
	default targetType = ECT_AlwaysPlayer;
	default betweenTargetAndSelf = true;
	
	hint animationEventName = "Name of the animation event of the owner - it will trigger the spawner, use only simple events";
	hint usableEntityTag = "Tag of all used spawners";
	hint maxTriggeredEntities = "Max number of spawners triggered with one use of this task";
	hint checkDistance = "The distance from target node, in which spawners will be found";
	hint delayBetweenUses = "Delay for the task availability, means that task can be used once per X seconds";
	hint minDistanceToSelf = "Min distance of the spawners to the owner of the task";
	hint targetType = "Type of the target node, if ECT_SpecifiedTag is chosen, you need to specify the tag of the node";
	hint targetTag = "Tag of the target node, used only when targetType is set to ECT_SpecifiedTag";
	hint betweenTargetAndSelf = "Will use entities that are between target and self";
}