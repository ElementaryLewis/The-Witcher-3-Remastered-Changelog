/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TrapTrigger extends W3GameplayTrigger
{
	
	
	
	
	private editable		var m_TrapsToActivateTag 			: name;																hint m_TrapsToActivateTag= "traps with this tag will be activated";
	private editable		var m_MaxActivation					: int;						default m_MaxActivation = -1; 			hint m_MaxActivation 	= "negative number means infinite activations";
	private editable		var m_DeactivateOnExit				: bool;						default m_DeactivateOnExit = true;		hint m_DeactivateOnExit = "The trap deactivates when the player leaves the trigger";
	private	editable		var m_Enabled						: bool;						default m_Enabled = true;
	private editable 		var m_playerOnly					: bool;						default	m_playerOnly = false;
	
	private editable 		var m_excludedEntitiesTags			: array <name>;
	private 				var m_trapsToActivateByTag			: array <CEntity>;
	
	private saved			var	m_Activations			: int;
	
	private 				var m_EntitiesInside		: int;
	
	hint m_TrapsToActivateTag 	= "All traps with this tag will be activated by this trigger";
	hint m_MaxActivation 		= "This trigger will work this amount of time";
	hint m_DeactivateOnExit 	= "When trigger is empty, it deactivates the traps";
	hint m_Enabled 				= "Trigger will only activate traps if true";
	hint m_playerOnly 			= "Only the player can trigger the traps";
	hint m_excludedEntitiesTags 	= "Entities with this tag will be ignored by the trigger";
	
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		if(!spawnData.restored)
			m_Activations = 0;
			
	}
	
	
	
	public function Enable( _NewState : bool )
	{
		m_Enabled = _NewState;
	}	
	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var i 				: int;
		var k 				: int;
		var l_trap			: W3Trap;		
		
		if( !m_Enabled ) return false;
		
		if ( m_playerOnly  && activator.GetEntity() != thePlayer )
		{
			return false;
		}
		
		if( (m_MaxActivation >= 0) && (m_Activations >= m_MaxActivation) ) return false;
		
		if( ShouldExcludeEntity( activator.GetEntity() ) ) return false;
		
		theGame.GetEntitiesByTag ( m_TrapsToActivateTag, m_trapsToActivateByTag );
		
		if ( m_trapsToActivateByTag.Size() > 0 )
		{
			for( k = 0; k < m_trapsToActivateByTag.Size(); k += 1 )
			{
				l_trap = (W3Trap)m_trapsToActivateByTag[k];
				l_trap.Activate( activator );
			}
		}
		m_Activations+=1;
		m_EntitiesInside += 1;
		return true;
	}
	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var i 		: int;
		var k 		: int;
		var l_trap	: W3Trap;
		
		if( !m_Enabled ) return false;
		
		if ( m_playerOnly  && activator.GetEntity() != thePlayer )
		{
			return false;
		}
		
		if( ShouldExcludeEntity( activator.GetEntity() ) ) return false;
		
		m_EntitiesInside -= 1;
		
		
		if ( m_trapsToActivateByTag.Size() > 0 )
		{
			for( k = 0; k < m_trapsToActivateByTag.Size(); k += 1 )
			{
				l_trap = (W3Trap)m_trapsToActivateByTag[k];
				
				l_trap.RemoveTarget( activator );
				
				if( m_DeactivateOnExit && m_EntitiesInside == 0 )
				{
					l_trap.Deactivate();
				}
			}
		}
		
		
		return true;
	}
		
	
	
	private function ShouldExcludeEntity( _Entity : CNode ) : bool
	{
		var i				: int;
		var l_entityTags	: array <name>;
		
		if( _Entity && m_excludedEntitiesTags.Size() > 0 )
		{
			l_entityTags = _Entity.GetTags();
			for ( i = 0; i < m_excludedEntitiesTags.Size(); i += 1 )
			{
				if( l_entityTags.Contains( m_excludedEntitiesTags[i] ) )
				{
					return true;
				}
			}
		}
		
		return false;
	}
}
