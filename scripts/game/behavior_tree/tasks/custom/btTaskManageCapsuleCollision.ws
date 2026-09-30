/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class TaskManageCapsuleCollision extends IBehTreeTask
{
	var collision				: bool;
	var allCollisionTypes 		: bool;
	var overrideForThisTaskOnly	: bool;
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var onAnimEvent 			: bool;
	var switchVulnerability		: bool;
	var effectLinkedToCollision	: name;
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		if ( overrideForThisTaskOnly )
		{
			EnableCol( collision );
		}
		else if ( onActivate )
		{
			EnableCol( collision );
		}
			
		return BTNS_Active;
	}
	
	
	function OnDeactivate()
	{
		if ( overrideForThisTaskOnly  )
		{
			EnableCol( !collision );
		}
		else if ( onDeactivate  )
		{
			EnableCol( collision );
		}
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{		
		if( !onAnimEvent ) return false;
		
		if ( animEventName == 'EnableCollision' )
		{
			EnableCol( true );
		}
		else if ( animEventName == 'DisableCollision')
		{
			if( animEventType == AET_DurationEnd )
			{
				EnableCol( true );
			}
			else
			{
				EnableCol( false );
			}
			
		}
		else if ( animEventName == 'EnableCollisionDuration' )
		{
			if( animEventType == AET_DurationStart )
			{
				EnableCol( true );
			}
			else if( animEventType == AET_DurationEnd )
			{
				EnableCol( false );
			}
		}
		
		return true;
	}
		
	
	
	private function EnableCol( _Enable : bool )
	{
		var l_npc : CNewNPC = GetNPC();
		l_npc.EnableCharacterCollisions( _Enable );
		if ( allCollisionTypes )
		{
			l_npc.EnableCollisions( _Enable );
		}
		
		if( switchVulnerability )
		{
			if( _Enable )
			{
				l_npc.SetImmortalityMode( AIM_None, AIC_Combat );
			}
			else
			{
				l_npc.SetImmortalityMode( AIM_Invulnerable, AIC_Combat );
			}
			
		}
		
		if( IsNameValid( effectLinkedToCollision ) )
		{
			if( !_Enable &&  !l_npc.IsEffectActive( effectLinkedToCollision ) )
			{
				l_npc.PlayEffect( effectLinkedToCollision );
			}
			else if( _Enable )
			{
				l_npc.StopEffect( effectLinkedToCollision );
			}
		}
	}
}

class TaskManageCapsuleCollisionDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'TaskManageCapsuleCollision';

	editable var collision					: bool;
	editable var allCollisionTypes 			: bool;
	editable var overrideForThisTaskOnly	: bool;
	editable var onActivate 				: bool;
	editable var onDeactivate 				: bool;
	editable var onAnimEvent				: bool;
	editable var switchVulnerability		: bool;
	editable var effectLinkedToCollision	: name;
	
	hint onAnimEvent 				= "EnableCollision or DisableCollision anim events";
	hint switchVulnerability		= "Should the NPC be turn invulnerable when collision is off and vulnerable when on";
	hint abilityName				= "Name of the ability required for this node to work";
	hint effectLinkedToCollision	= "Effect will be played when collision is off, and stop when collision is on";
	
	default switchVulnerability 	= true;
};