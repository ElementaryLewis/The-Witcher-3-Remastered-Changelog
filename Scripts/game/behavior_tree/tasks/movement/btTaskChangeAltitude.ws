/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskChangeAltitude extends IBehTreeTask
{
	var HighFlightChance 		: float;
	var LowFlightChance 		: float;
	var LandChance				: float;
	var onActivate 				: bool;
	var onDeactivate 			: bool;
	var onMain					: bool;
	var frequency 				: float;
	var lastChange				: float;
	
	default lastChange = 0.f;
	
	function IsAvailable() : bool
	{
		return true;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		
		while( onMain )
		{
			Sleep( frequency );
			FlightStyleChange();
		}
		return BTNS_Active;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			FlightStyleChange();
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			FlightStyleChange();
		}
	}
	
	function IsHighFlight() : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( npc.GetBehaviorVariable( '2high' ) == 1 )
		{
			return true;
		}
		return false;
	}
	
	function IsLowFlight() : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( npc.GetBehaviorVariable( '2low' ) == 1 )
		{
			return true;
		}
		return false;
	}
	
	function IsOnGround() : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( npc.GetBehaviorVariable( '2ground' ) == 1 )
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
		if ( IsHighFlight() )
		{
			if ( RandF() < LowFlightChance )
			{
				npc.ChangeStance( NS_Retreat );
				npc.SetBehaviorVariable( '2high', 0 );
				npc.SetBehaviorVariable( '2low', 1 );
				npc.SetBehaviorVariable( '2ground', 0 );
			}
			else if ( RandF() < LandChance )
			{
				npc.ChangeStance( NS_Normal );
				npc.SetBehaviorVariable( '2high', 0 );
				npc.SetBehaviorVariable( '2low', 0 );
				npc.SetBehaviorVariable( '2ground', 1 );
			}
			lastChange = GetLocalTime();
		}
		else if( IsLowFlight() )
		{
			if ( RandF() < HighFlightChance )
			{
				npc.ChangeStance( NS_Retreat );
				npc.SetBehaviorVariable( '2high', 1 );
				npc.SetBehaviorVariable( '2low', 0 );
				npc.SetBehaviorVariable( '2ground', 0 );
			}
			if ( RandF() < LandChance )
			{
				npc.ChangeStance( NS_Normal );
				npc.SetBehaviorVariable( '2high', 0 );
				npc.SetBehaviorVariable( '2low', 0 );
				npc.SetBehaviorVariable( '2ground', 1 );
			}
			lastChange = GetLocalTime();
		}
		else if( IsOnGround() )
		{
			if ( RandF() < HighFlightChance )
			{
				npc.ChangeStance( NS_Retreat );
				npc.SetBehaviorVariable( '2high', 1 );
				npc.SetBehaviorVariable( '2low', 0 );
				npc.SetBehaviorVariable( '2ground', 0 );
			}
			if ( RandF() < LowFlightChance )
			{
				npc.ChangeStance( NS_Retreat );
				npc.SetBehaviorVariable( '2high', 0 );
				npc.SetBehaviorVariable( '2low', 1 );
				npc.SetBehaviorVariable( '2ground', 0 );
			}
			lastChange = GetLocalTime();
		}
	}
}

class CBTTaskChangeAltitudeDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskChangeAltitude';

	editable var onActivate 			: bool;
	editable var onDeactivate 			: bool;
	editable var onMain					: bool;
	editable var HighFlightChance 		: float;
	editable var LowFlightChance 		: float;
	editable var LandChance				: float;
	editable var frequency 				: float;
	
	default onActivate			= true;
	default onDeactivate 		= false;
	default onMain				= false;
	
	default frequency = 5.0;
	default HighFlightChance = 0.5;
	default LowFlightChance = 0.5;
	default LandChance = 0.5;
}