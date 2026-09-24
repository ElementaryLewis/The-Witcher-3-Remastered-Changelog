/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskStopYrden extends IBehTreeTask
{
	var npc 					: CNewNPC;
	var yrden					: W3YrdenEntity;
	var yrdenIsActionTarget		: bool;
	var range					: float;
	var useYrdenRadiusAsRange	: bool;
	var maxResults				: int;
	var onActivate				: bool;
	var onDeactivate			: bool;
	var onAnimEvent 			: bool;
	var eventName 				: name;
	var stopYrdenShock			: bool;
		
	function OnActivate() : EBTNodeStatus
	{
		npc = GetNPC();
		
		if( yrdenIsActionTarget && onActivate )
		{
			yrden = (W3YrdenEntity)GetActionTarget();
			StopYrden( yrden );
		}
		else if( onActivate )
		{
			FindAndStopNearYrdenEntities();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		if( yrdenIsActionTarget && onDeactivate )
		{
			yrden = (W3YrdenEntity)GetActionTarget();
			StopYrden( yrden );
		}
		else if( onDeactivate )
		{
			FindAndStopNearYrdenEntities();
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if( onAnimEvent && animEventName == eventName ) 
		{
			FindAndStopNearYrdenEntities();
		}
		
		return true;
	}
	
	private function FindAndStopNearYrdenEntities()
	{	
		var i			: int;
		var l_entities 	: array<CGameplayEntity>;
		var l_yrden		: W3YrdenEntity;
		var min, max 	: SAbilityAttributeValue;
		
		npc.RemoveAllBuffsOfType( EET_Burning );
		npc.RemoveAllBuffsOfType( EET_Frozen );
		npc.RemoveAllBuffsOfType( EET_Bleeding );
		npc.RemoveAllBuffsOfType( EET_SlowdownFrost );
		npc.RemoveAllBuffsOfType( EET_Slowdown );
		
		
		npc.RemoveAllBuffsOfType( EET_Bleeding1 );
		npc.RemoveAllBuffsOfType( EET_Bleeding2 );
		npc.RemoveAllBuffsOfType( EET_Bleeding3 );
		
		
		l_entities.Clear();
		
		if( useYrdenRadiusAsRange )
		{
			range = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'range', false, true) );
			
			if( GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
				range *=  min.valueAdditive;
			}
			
			range += GetNPC().GetRadius();
		}
		
		FindGameplayEntitiesInSphere( l_entities, npc.GetWorldPosition(), range, maxResults );
		
		for( i = 0; i < l_entities.Size(); i += 1 )
		{
			l_yrden = (W3YrdenEntity) l_entities[i];
			if( l_yrden )
			{
				StopYrden( l_yrden );
			}
		}
	}
	
	private function StopYrden( yrdenEntity : W3YrdenEntity )
	{
		var yrdenShock : W3YrdenEntityStateYrdenShock;
		
		yrdenShock = (W3YrdenEntityStateYrdenShock)yrdenEntity.GetCurrentState();
		
		if( yrdenShock && stopYrdenShock || !yrdenShock )
		{
			yrdenEntity.TimedCanceled( 0, 0 );
			yrdenEntity.OnSignAborted( true );
		}
	}
}

class CBTTaskStopYrdenDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskStopYrden';
	
	editable var yrdenIsActionTarget	: bool;
	editable var range					: float;
	editable var useYrdenRadiusAsRange	: bool;
	editable var maxResults				: int;
	editable var onActivate				: bool;
	editable var onDeactivate			: bool;
	editable var onAnimEvent 			: bool;
	editable var eventName 				: name;
	editable var stopYrdenShock			: bool;
	
	default stopYrdenShock = true;
}





class CBTTaskIsInYrden extends IBehTreeTask
{
	
	
	function IsAvailable() : bool
	{
		return IsInYrden();
	}

	function IsInYrden() : bool
	{	
		var i : int;
		var entities : array<CGameplayEntity>;
		var yrden : W3YrdenEntity;
		var range : float;
		var min, max : SAbilityAttributeValue;
		
		range = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'range', false, true) );
			
		if( GetWitcherPlayer().IsSetBonusActive( EISB_Gryphon_2 ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'GryphonSetBonusYrdenEffect', 'trigger_scale', min, max );
			range *=  min.valueAdditive;
		}
		
		range += GetNPC().GetRadius();
				
		entities.Clear();	
		FindGameplayEntitiesInSphere( entities, GetNPC().GetWorldPosition(), range, 99 ); 
		
		for( i = 0; i < entities.Size(); i += 1 )
		{
			yrden = (W3YrdenEntity)entities[i];
			
			if( yrden )
			{
				return true;
			}
		}
		
		return false;
	}
	
}
class CBTTaskIsInYrdenDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskIsInYrden';
}