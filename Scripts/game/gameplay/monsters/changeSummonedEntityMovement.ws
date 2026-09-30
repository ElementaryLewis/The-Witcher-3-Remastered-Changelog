/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskChangeSummonedEntityMovement extends IBehTreeTask
{
	
	
	
	public var	speed 							: float;
	public var	stopDistance 					: float;
	public var	fallBackSpeed 					: float;
	public var	normalSpeed						: float;
	public var	verticalSpeed					: float;
	
	public var	speedOscilation					: SRangeF;
	public var	normalSpeedOscilation			: SRangeF;
	public var	verticalOscilation				: SRangeF;
	
	public var	speedOscilationSpeed			: float;
	public var	normalSpeedOscilationSpeed		: float;
	public var	verticalOscilationSpeed			: float;
	
	private var m_summonerCmp					: W3SummonerComponent;
	
	
	function Initialize()
	{
		m_summonerCmp = ( W3SummonerComponent ) GetNPC().GetComponentByClassName('W3SummonerComponent');
	}
	
	
	function IsAvailable() : bool
	{
		var l_summonedEntities 	: array<CEntity>;
		l_summonedEntities = m_summonerCmp.GetSummonedEntities();
		return l_summonedEntities.Size() > 0;
	}
	
	
	function OnActivate() : EBTNodeStatus
	{
		ChangeValues( );
		return BTNS_Active;
	}		
	
	
	private function ChangeValues( )
	{
		var i 					: int;
		var l_summonedEntities 	: array<CEntity>;
		var l_entity			: CEntity;
		var l_slideCmp 			: W3SlideToTargetComponent;
		
		l_summonedEntities = m_summonerCmp.GetSummonedEntities();
		for( i = 0; i < l_summonedEntities.Size(); i += 1 )
		{
			l_entity 		= l_summonedEntities[i];
			l_slideCmp 		= (W3SlideToTargetComponent) l_entity.GetComponentByClassName('W3SlideToTargetComponent');
			if( l_slideCmp )
			{
				l_slideCmp.SetSpeedOscillation( speedOscilation.min, speedOscilation.max, speedOscilationSpeed );				
				l_slideCmp.SetNormalSpeedOscillation( normalSpeedOscilation.min, normalSpeedOscilation.max, normalSpeedOscilationSpeed );
				l_slideCmp.SetVerticalOscillation( verticalOscilation.min, verticalOscilation.max, verticalOscilationSpeed );
				
				l_slideCmp.SetStopDistance( stopDistance );
				l_slideCmp.SetSpeed( speed );
				l_slideCmp.SetFallBackSpeed( fallBackSpeed );
				l_slideCmp.SetNormalSpeed( normalSpeed );
				l_slideCmp.SetVerticalSpeed( verticalSpeed );
				
			}
		}		
	}
}




class BTTaskChangeSummonedEntityMovementDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskChangeSummonedEntityMovement';

	
	
	private editable var	speed 							: float;
	private editable var	stopDistance					: float;
	private editable var	fallBackSpeed					: float;
	private editable var	normalSpeed						: float;
	private editable var	verticalSpeed					: float;
	
	private editable var	speedOscilation					: SRangeF;
	private editable var	normalSpeedOscilation			: SRangeF;
	private editable var	verticalOscilation				: SRangeF;
	
	private editable var	speedOscilationSpeed			: float;
	private editable var	normalSpeedOscilationSpeed		: float;
	private editable var	verticalOscilationSpeed			: float;
}