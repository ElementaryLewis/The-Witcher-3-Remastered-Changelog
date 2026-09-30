/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskFlightStyle extends IBehTreeTask
{
	var GlideChance				: float;
	var BackToRegularChance		: float;
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var onMain					: bool;
	var glideCheck				: bool;
	var backToRegularCheck		: bool;
	var altitudeCheck			: bool;
	var altitude				: float;
	var frequency 				: float;
	var lastChange				: float;
	var actorPosition			: Vector;
	
	default lastChange = 0.f;
	default altitude = 4.f;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		while( onMain )
		{
			Sleep( frequency );
			actorPosition = npc.GetWorldPosition();
			
			if( actorPosition.Z < altitude )
			{
				npc.SetBehaviorVariable( 'Fly2Glide', 0 );
			}
			else
			{
				FlightStyleChange();
			}
		}
		return BTNS_Active;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( onActivate )
		{
			actorPosition = npc.GetWorldPosition();
			
			if( actorPosition.Z < altitude )
			{
				npc.SetBehaviorVariable( 'Fly2Glide', 0 );
			}
			else
			{
				FlightStyleChange();
			}
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		if ( onDeactivate )
		{
			actorPosition = npc.GetWorldPosition();
			
			if( actorPosition.Z < altitude )
			{
				npc.SetBehaviorVariable( 'Fly2Glide', 0 );
			}
			else
			{
				FlightStyleChange();
			}
		}
		else
		{
			npc.SetBehaviorVariable( 'Fly2Glide', 0 );
		}
	}
	
	function IsAlternateFlightStyle() : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( npc.GetBehaviorVariable( 'Fly2Glide' ) == 1 )
		{
			return true;
		}
		return false;
	}
	
	function FlightStyleChange()
	{
		var npc : CNewNPC = GetNPC();
		
		if ( lastChange + frequency >= GetLocalTime() )
		{
			return;
		}
		if ( backToRegularCheck && IsAlternateFlightStyle() )
		{
			if ( RandF() < BackToRegularChance )
			{
				npc.SetBehaviorVariable( 'Fly2Glide', 0 );
			}
			lastChange = GetLocalTime();
		}
		else if ( glideCheck )
		{
			actorPosition = npc.GetWorldPosition();			
			
			if ( glideCheck && ( RandF() < GlideChance ) && actorPosition.Z > altitude )
			{
				npc.SetBehaviorVariable( 'Fly2Glide', 1 );
			}
			lastChange = GetLocalTime();
		}
	}
}

class CBTTaskFlightStyleDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskFlightStyle';

	editable var onActivate 			: bool;
	editable var onDeactivate 			: bool;
	editable var onMain					: bool;
	editable var glideCheck				: bool;
	editable var backToRegularCheck		: bool;
	editable var altitudeCheck			: bool;
	editable var GlideChance			: float;
	editable var BackToRegularChance	: float;
	editable var altitude		 		: float;
	editable var frequency 				: float;
	
	default onActivate			= true;
	default onDeactivate 		= false;
	default onMain				= false;
	default glideCheck 			= true;
	default backToRegularCheck 	= true;
	default altitudeCheck		= true;
	
	default frequency = 2.0;
	default GlideChance = 0.5;
	default BackToRegularChance = 1.0;
	default altitude = 4.f;
}