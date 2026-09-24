/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskForceFinisher extends IBehTreeTask
{
	
	
	
	private var belowHealthPercent				: float;
	private var whenAlone						: bool;
	private var leftStanceFinisherAnimName 		: name;
	private var rightStanceFinisherAnimName 	: name;
	private var hasFinisherDLC					: bool;
	private var shouldCheckForFinisherDLC		: bool;
	
	private var m_Npc							: CNewNPC;
	
	
	
	function Initialize()
	{
		hasFinisherDLC = theGame.GetDLCManager().IsDLCEnabled( 'dlc_016_001' );
		m_Npc = GetNPC();		
	}
	
	
	
	latent function Main() : EBTNodeStatus
	{
		while(true)
		{
			if ( belowHealthPercent > 0 && GetNPC().GetHealthPercents() < belowHealthPercent )
				ForceFinisher( true );
			else if ( whenAlone && NumberOfOpponents() <= 1 )
				ForceFinisher( true );
			else
				ForceFinisher( false );
			
			Sleep( 1.0 );
		}
		
		return BTNS_Active;
	}
	
	
	
	private function ForceFinisher( b : bool )
	{
		var l_player : CR4Player = thePlayer;
		
		if ( !b )
		{
			l_player.forceFinisher = false;
		}
		else if ( shouldCheckForFinisherDLC && !hasFinisherDLC )
		{
			Log( "No Finisher DLC enabled. Executing default finisher");
			ForceDefaultFinisher( true );
		}
		else if ( l_player.GetCombatIdleStance() == 0 )
		{
			l_player.forceFinisher = true;
			l_player.forcedStance = 0;
			l_player.forceFinisherAnimName = leftStanceFinisherAnimName;
		}
		else
		{
			l_player.forceFinisher = true;
			l_player.forcedStance = 1;
			l_player.forceFinisherAnimName = rightStanceFinisherAnimName;
		}
	}
	
	
	
	private function ForceDefaultFinisher( b : bool )
	{
		var l_player : CR4Player = thePlayer;
		
		if ( !b )
		{
			l_player.forceFinisher = false;
		}
		else if ( l_player.GetCombatIdleStance() == 0 )
		{
			l_player.forceFinisher = true;
			l_player.forcedStance = 0;
			l_player.forceFinisherAnimName = 'man_finisher_05_rp';
		}
		else
		{
			l_player.forceFinisher = true;
			l_player.forcedStance = 1;
			l_player.forceFinisherAnimName = 'man_finisher_06_lp';
		}
	}
	
	
	
	private function NumberOfOpponents() : int
	{
		var target 				: CActor = GetCombatTarget();
		var targetCombatData 	: CCombatDataComponent;
		var opponentsNum		: int;
		
		targetCombatData = (CCombatDataComponent) target.GetComponentByClassName('CCombatDataComponent');
		opponentsNum = -1;
		if( targetCombatData )
		{			
			opponentsNum = targetCombatData.GetAttackersCount();	
		}
			return opponentsNum;
	}
	
	
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var l_player : CR4Player = thePlayer;
		
		if( eventName == 'Death' )
		{
			l_player.AddTimer('RemoveForceFinisher', 3, false, , , true );
		}
		
		return true;
	}
}



class BTTaskForceFinisherDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskForceFinisher';
	
	editable var belowHealthPercent 					: float;
	editable var whenAlone						: bool;
	editable var leftStanceFinisherAnimName 	: name;
	editable var rightStanceFinisherAnimName 	: name;	
	editable var shouldCheckForFinisherDLC		: bool;
	var hasFinisherDLC							: bool;
	
	default belowHealthPercent = -1;
	default whenAlone = true;
	default leftStanceFinisherAnimName = 'man_finisher_04_lp';
	default rightStanceFinisherAnimName = 'man_finisher_05_rp';
	
	
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'Death' );
	}
}