/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TrapTripwire extends W3Trap
{
	
	
	
	
	editable inlined var eventOnTripped 		: array < IPerformableAction >;	
	editable saved  var maxUseCount				: int; default maxUseCount = 1;
	private editable var excludedActorsTags		: array <name>;
	
	
	hint	eventOnTripped				= "Event to fire when actor trips tripwire";
	hint 	excludedActorsTags 			= "Actors with these tags won't trigger the trap when entering the area";
	
	default soundOnDisarm = 'qu_item_wire_cutter';
	
	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var l_actor	: CActor;
		l_actor = (CActor) activator.GetEntity();
		
		if( l_actor && ShouldExcludeActor( l_actor ) ||  maxUseCount == 0 )
		{
			return true;
		}	
		
		if ( m_isArmed && l_actor )
		{
			Activate( l_actor );
		}
	}
	
	
	private function ShouldExcludeActor( _Actor : CActor ) : bool
	{
		var i			: int;
		var actorTags	: array <name>;
		
		if( _Actor && excludedActorsTags.Size() > 0 )
		{
			actorTags = _Actor.GetTags();
			for ( i = 0; i < excludedActorsTags.Size(); i += 1 )
			{
				if( actorTags.Contains( excludedActorsTags[i] ) )
				{
					return true;
				}
			}
		}
		return false;
	}
	
	
	
	public function Activate( optional _Target: CNode ):void
	{
		var passedNode : CActor;
		
		SpringTripwire(_Target);
		
		super.Activate( _Target );
	}
	
	
	function SpringTripwire(_Target : CNode)
	{
		TriggerPerformableEventArgNode( eventOnTripped, this, _Target );
		this.PlayEffect('trap_sprung');
		
		if ( maxUseCount != -1 )
		{
			maxUseCount -=1;
		}
		
		if ( maxUseCount == 0 )
		{
			m_isArmed = false;
			m_IsActive = false;
		}
	}
}