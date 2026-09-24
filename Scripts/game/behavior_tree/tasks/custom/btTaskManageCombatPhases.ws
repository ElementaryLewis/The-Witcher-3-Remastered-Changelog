/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SCombatPhaseParameters
{
	editable var setBehVariable 			: int;
	editable var priority					: float;
	editable var duration 					: float;
	editable var cooldown 					: float;
	editable var timerRandomization 		: float;
	editable var minRangeFromTarget 		: float;
	editable var maxRangeFromTarget 		: float;
	editable var activationAnimEvent 		: name;
	editable var deactivationAnimEvent 		: name;
	editable var activationGameplayEvent 	: name;
	editable var deactivationGameplayEvent 	: name;
}

class BTTaskManageCombatPhases extends IBehTreeTask
{
	
	
	
	
	public var rangedCombatPhaseParameters	: SCombatPhaseParameters;
	public var closeCombatPhaseParameters	: SCombatPhaseParameters;
	public var nonCombatPhaseParameters		: SCombatPhaseParameters;
	public var availableCombatPhasesArray 	: array< SCombatPhaseParameters >;
	public var initialCombatPhasesArray 	: array< SCombatPhaseParameters >;
	public var combatPhasesArray 			: array< SCombatPhaseParameters >;
	public var setBehVariableName 			: name;
	
	
	private var activationEventReceived 	: float;
	private var rangedCombatTimeStamp 		: float;
	private var closeCombatTimeStamp 		: float;
	private var nonCombatTimeStamp 			: float;
	private var currentCombatPhase 			: int;
	private var afterFirstChoice 			: bool;
	
	default afterFirstChoice 				= false;
	
	
	
	function Initialize()
	{
		var i : int;
		
		initialCombatPhasesArray.PushBack( rangedCombatPhaseParameters );
		initialCombatPhasesArray.PushBack( closeCombatPhaseParameters );
		initialCombatPhasesArray.PushBack( nonCombatPhaseParameters );
		combatPhasesArray = initialCombatPhasesArray;
		
		for ( i=0 ; i<combatPhasesArray.Size() ; i+=1 )
		{
			combatPhasesArray[i].cooldown = 0;
			combatPhasesArray[i].duration = 0;
		}
	}	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc		: CNewNPC = GetNPC();
		var i, j, k : int;
		var tempF 	: float;
		
		while ( true )
		{
			Sleep( 0.1 );
			
			
			tempF = npc.GetBehaviorVariable( setBehVariableName );
			
			for ( i=0 ; i<combatPhasesArray.Size() ; i+=1 )
			{
				if ( combatPhasesArray[i].setBehVariable == tempF )
				{
					currentCombatPhase = i;
					break;
				}
			}
			
			
			for ( k=0 ; k<combatPhasesArray.Size() ; k+=1 )
			{
				if ( combatPhasesArray[k].cooldown >= 0.1 )
				{
					combatPhasesArray[k].cooldown -= 0.1;
				}
			}
			
			
			if ( combatPhasesArray[currentCombatPhase].duration >= 0.1 )
			{
				combatPhasesArray[currentCombatPhase].duration -= 0.1;
			}
			
			else
			{
				
				if ( afterFirstChoice )
				{
					combatPhasesArray[currentCombatPhase].cooldown = initialCombatPhasesArray[currentCombatPhase].cooldown 
						- ( initialCombatPhasesArray[currentCombatPhase].cooldown * RandRangeF( initialCombatPhasesArray[currentCombatPhase].timerRandomization, 0 ));
				}
				j = CheckCombatPhase();
				npc.SetBehaviorVariable( setBehVariableName, availableCombatPhasesArray[j].setBehVariable );
				
				for ( i=0 ; i<combatPhasesArray.Size() ; i+=1 )
				{
					if ( combatPhasesArray[i].setBehVariable == tempF )
					{
						currentCombatPhase = i;
						break;
					}
				}
				
				combatPhasesArray[currentCombatPhase].duration = initialCombatPhasesArray[currentCombatPhase].duration 
					- ( initialCombatPhasesArray[currentCombatPhase].duration * RandRangeF( initialCombatPhasesArray[currentCombatPhase].timerRandomization, 0 ));
			}
		}
		
		return BTNS_Active;
	}
	
	
	
	
	
	final function CheckCombatPhase() : int
	{
		var i, j : int;
		
		afterFirstChoice = true;
		availableCombatPhasesArray = combatPhasesArray;
		
		
		for ( i=0 ; i<availableCombatPhasesArray.Size() ; i+=1 )
		{
			if ( availableCombatPhasesArray[i].cooldown > 0 )
			{
				availableCombatPhasesArray.Erase(i);
			}
		}
		
		
		j = ArrayFindMaxPriorityFloatFromStruct( availableCombatPhasesArray );
		
		return j;
	}
	
	
	final function ArrayFindMaxPriorityFloatFromStruct( a : array< SCombatPhaseParameters > ) : int
	{
		var i, s, index : int;
		var val : float;	
		
		s = a.Size();
		if( s > 0 )
		{
			index = 0;
			val = a[0].priority;
			for( i=1; i<s; i+=1 )
			{
				if( a[i].priority > val )
				{
					index = i;
					val = a[i].priority;
				}
			}
			
			return index;
		}
		
		return -1;			
	}
	
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == '' )
		{
			return true;
		}
		
		return false;
	}
	
	
	
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == '' )
		{
			return true;
		}
		
		return false;
	}
};



class BTTaskManageCombatPhasesDef extends IBehTreeTaskDefinition
{
	
	
	
	editable var rangedCombatPhaseParameters	: SCombatPhaseParameters;
	editable var closeCombatPhaseParameters		: SCombatPhaseParameters;
	editable var nonCombatPhaseParameters		: SCombatPhaseParameters;
	editable var setBehVariableName 			: name;
	
	default instanceClass = 'BTTaskManageCombatPhases';
};
