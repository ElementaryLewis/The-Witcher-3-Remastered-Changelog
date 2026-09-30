/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TrapDestructSelf extends W3Trap
{
	
	
	
	private editable var playEffectOnDestruct			: name;
	private editable var onlyDestructOnAreaEnter		: bool;
	private editable var denyAreaAfterDestruction		: bool;
	private editable var excludedActorsTags				: array <name>;
	private editable var excludesblockDestruction		: bool;
	
	private var m_actorsInTrigger	: array<CActor>;
	private var m_isDestroyed		: bool;
	
	default denyAreaAfterDestruction = true;
	
	default excludesblockDestruction = true;
	
	hint denyAreaAfterDestruction = "should it activates the deniedArea that prevent npc from walking over after activation";
	hint excludesblockDestruction = "if one of the excluded actor is in the trigger, do not activate the trap";

	
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var l_actor	: CActor;
		l_actor = (CActor) activator.GetEntity();
		
		if( area.GetName() == "DetectActors" )
		{
			
			if( l_actor && excludesblockDestruction )
			{
				m_actorsInTrigger.PushBack( l_actor );
			}
			return true;
		}
		
		if ( onlyDestructOnAreaEnter &&  m_IsActive )
		{			
			if( l_actor && ShouldExcludeActor( l_actor ) )
			{
				return false;
			}
			
			if( excludesblockDestruction && ExcludedActorIsInArea() ) 
			return false;
			
			DestructSelf();
		}		
	}
	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		var l_actor	: CActor;
		
		if( area.GetName() == "DetectActors" && excludesblockDestruction ) 
		{
			l_actor = (CActor) activator.GetEntity();		
			m_actorsInTrigger.Remove( l_actor );
		}		
	}
	
	
	private final function ExcludedActorIsInArea() : bool 
	{
		var i : int;
		for ( i = 0; i < m_actorsInTrigger.Size(); i += 1 )
		{
			if( ShouldExcludeActor( m_actorsInTrigger[i] ) )
			{
				return true;
			}
		}
		
		return false;
	}
	
	
	private final function ShouldExcludeActor( _Actor : CActor ) : bool
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
	
	
	
	public final function Activate( optional _Target: CNode ):void
	{		
		if( m_isDestroyed ) return;
		
		if( excludesblockDestruction && ExcludedActorIsInArea() ) 
			return;
		
		if( !m_IsActive && !onlyDestructOnAreaEnter )
		{
			DestructSelf();
		}		
		super.Activate( _Target );
	}
	
	
	private final function DestructSelf()
	{
		var l_invisibleCollision : CComponent;
		var l_destructionCmp 	: CDestructionSystemComponent;
		var l_deniedArea		: CDeniedAreaComponent;
		if( m_isDestroyed ) return;
		
		PlayEffect( playEffectOnDestruct );
		
		l_destructionCmp = (CDestructionSystemComponent) GetComponentByClassName('CDestructionSystemComponent');
		
		if( l_destructionCmp )
		{
			l_destructionCmp.ApplyFracture();
		}
		else
		{
			Destroy();
		}
		
		l_deniedArea = (CDeniedAreaComponent) GetComponentByClassName('CDeniedAreaComponent');
		if( l_deniedArea )
		{
			l_deniedArea.SetEnabled( true );
		}
		
		m_isDestroyed = true;
	}
	
	
}