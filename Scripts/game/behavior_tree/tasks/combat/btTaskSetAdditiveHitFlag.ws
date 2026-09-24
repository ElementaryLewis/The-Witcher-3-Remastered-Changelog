/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetAdditiveHitFlag extends IBehTreeTask
{	
	public var onDeactivate 			: bool;
	public var onAnimEvent				: name;
	public var flag						: bool;
	public var additiveHits				: bool;
	public var additiveCriticalStates	: bool;
	public var overrideOnly				: bool;
	public var playNormalHitOnCritical	: bool;
	
	private var m_valueOnActivate		: bool;
	private var m_csValueOnActivate		: bool;
	
	private var m_waitingForEventEnd	: bool;
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		m_valueOnActivate = npc.UseAdditiveHit();
		m_csValueOnActivate = npc.UseAdditiveCriticalState();
		
		if( !onDeactivate )
			Execute( flag, flag );
		return BTNS_Active;
	}
	
	
	private function OnDeactivate()
	{
		if( onDeactivate )
			Execute( flag, flag );
			
		if( overrideOnly )
			Execute( m_valueOnActivate, m_csValueOnActivate );
			
		if( m_waitingForEventEnd )
		{
			Execute( !flag, !flag );
		}
		m_waitingForEventEnd = false;
	}
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{	
		if( animEventName == onAnimEvent && animEventType != AET_DurationEnd && animEventType != AET_Duration )
		{
			Execute( flag, flag );
			m_waitingForEventEnd = true;
		}
		else if( animEventName == onAnimEvent && animEventType == AET_DurationEnd )
		{
			Execute( !flag, !flag );
			m_waitingForEventEnd = false;
		}
		
		return true;
	}
	
	
	private function Execute( _Flag : bool, _criticalStateFlag : bool )
	{
		var npc : CNewNPC = GetNPC();
		if ( additiveHits )
			npc.SetUseAdditiveHit( _Flag, playNormalHitOnCritical );
		if ( additiveCriticalStates )
			npc.SetUseAdditiveCriticalStateAnim( _criticalStateFlag );
	}
}

class BTTaskSetAdditiveHitFlagDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetAdditiveHitFlag';
	
	editable var onDeactivate 				: bool;
	editable var onAnimEvent				: name;	
	editable var flag						: bool;
	editable var additiveHits				: bool;
	editable var additiveCriticalStates		: bool;
	editable var overrideOnly				: bool;
	editable var playNormalHitOnCritical	: bool;
	
	default flag			= true;
	default overrideOnly 	= true;
	default additiveHits	= true;
	
	hint overrideOnly = "reset to the previous value on deactivate";
	hint overrideOnly = "reset to the previous value on deactivate";
}

