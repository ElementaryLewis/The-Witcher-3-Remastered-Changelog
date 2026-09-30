/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EGuardState
{
	GS_Idle,
	GS_Chase,
	GS_Retreat,
};
	
class CBTTaskGuard extends IBehTreeTask
{
	var guardArea : CAreaComponent;
	var pursuitArea : CAreaComponent;
	var pursuitRange : float;
	var retreatType : EMoveType;
	var retreatSpeed : float;
	var intruderTestFrequency : float;
	
	var intruderTestTimeout : float;
	var guardState : EGuardState;
	var intruders : array<CGameplayEntity>; 
	var target : CActor;
	
	default guardState = GS_Idle;
	
	function OnActivate() : EBTNodeStatus
	{
		guardState = GS_Chase;
		if( intruders.Size() > 0 )
		{
			target = (CActor)intruders[0];
			return BTNS_Active;
		}
		
		return BTNS_Failed;
	}
	
	function IsAvailable() : bool
	{	
		var npc				: CNewNPC = GetNPC();

		if( !npc.IsAlive() )
		{
			return false;
		}		
		
		if( guardState != GS_Idle )
		{
			return true;
		}
		
		GetIntruders();
		if( intruders.Size() > 0 )
		{
			return true;
		}
						
		return false;
	}
	
	function GetIntruders()
	{
		var npc				: CActor = GetActor();	
		var box 			: Box;
		
		box = guardArea.GetBoundingBox();
		FindGameplayEntitiesInBox(intruders, npc.GetWorldPosition(), box, 10, '', FLAG_ExcludeTarget, npc );     
	}
	
	latent function Main() : EBTNodeStatus
	{	
		var npc				: CActor = GetActor();	
	
		while( true )
		{
			
			GetIntruders();
					
			switch( guardState )
			{
				
				case GS_Chase:
					if( target && target.IsAlive() ) 
					{
						
						if( !intruders.Contains( target ) )
						{
							
							
							
							if( pursuitArea )
							{
								if( !pursuitArea.TestEntityOverlap( target ) )
								{
									guardState = GS_Retreat;
									break;
								}
							}
							
							else
							{
								if( VecDistanceSquared( guardArea.GetWorldPosition(), target.GetWorldPosition() ) < pursuitRange )
								{
									guardState = GS_Retreat;
									break;
								}
							}
						}	
						npc.ActionMoveTo( target.GetWorldPosition(), retreatType, retreatSpeed );
					}
					else
					{
						guardState = GS_Retreat;
					}
				break;
				
				case GS_Retreat:
					
					if( guardArea.TestEntityOverlap( npc ) )
					{
						guardState = GS_Idle;
					}
					else
					{
						npc.ActionMoveTo( guardArea.GetWorldPosition(), retreatType, retreatSpeed );
					}
				break;
			}		
			Sleep( intruderTestTimeout );
		}
		
		return BTNS_Active;
	}
}

class CBTTaskGuardDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskGuard';
	
	editable var guardArea_var : name;
	editable var guardPursuitArea_var : name;
	editable var guardPursuitRange : CBehTreeValFloat;
	editable var guardRetreatType : CBTEnumMoveType;
	editable var guardRetreatSpeed : CBehTreeValFloat;
	editable var guardIntruderTestFrequency : CBehTreeValFloat;
	
	function Initialize()
	{
		guardRetreatType.SetVal( 1 );
		SetValFloat( guardPursuitRange, 10.0f );
		SetValFloat( guardRetreatSpeed, 2.0f );
		SetValFloat( guardIntruderTestFrequency, 2.0f );
	}
	
	function OnSpawn( taskGen : IBehTreeTask )
	{
		var guardArea : CEntity;
		var pursuitArea : CEntity;
		var guardAreaAC : CComponent;
		var pursuitAreaAC : CComponent;
		var task : CBTTaskGuard;
		task = (CBTTaskGuard) taskGen;
		
		guardArea = (CEntity)GetObjectByVar( guardArea_var );
		if( guardArea )
		{
			guardAreaAC = guardArea.GetComponentByClassName('CTriggerAreaComponent');
			if( guardAreaAC )
			{
				task.guardArea = (CAreaComponent)guardAreaAC;
			}
		}
		
		pursuitArea = (CEntity)GetObjectByVar( guardPursuitArea_var );
		if( pursuitArea )
		{
			pursuitAreaAC = pursuitArea.GetComponentByClassName('CTriggerAreaComponent');
			if( pursuitAreaAC )
			{
				task.pursuitArea = (CAreaComponent)pursuitAreaAC;
			}
		}
		
		task.pursuitRange = GetValFloat( guardPursuitRange );
		task.pursuitRange = task.pursuitRange*task.pursuitRange;
		task.retreatType = GetValEnum( guardRetreatType );
		task.retreatSpeed = GetValFloat( guardRetreatSpeed );
		task.intruderTestFrequency = GetValFloat( guardIntruderTestFrequency );
	}
}