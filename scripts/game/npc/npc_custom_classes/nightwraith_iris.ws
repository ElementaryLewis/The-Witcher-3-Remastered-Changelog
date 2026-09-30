/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3NightWraithIris extends CNewNPC
{
	
	
	
	private var m_CurrentHealthSection  : int;					default m_CurrentHealthSection 	= 4;
	private var m_ClosestPainting		: CNode;	
	private var m_TargetPainting		: W3IrisPainting;
	private var m_Paintings				: array<CNode>;
	
	private var m_WaitingForSpawnEnd	: bool;					default m_WaitingForSpawnEnd 	= true;
	
	
	
	
	public function GetPortal() : W3IrisPainting
	{
		return m_TargetPainting;
	}
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var l_MAC : CMovingPhysicalAgentComponent;
		super.OnSpawned( spawnData );		
		theGame.GetNodesByTag( 'q604_painting', m_Paintings );
		
		
		
		
		
	}
		
	
	
	event OnBehaviorGraphNotification( notificationName : name, stateName : name )
	{
		super.OnBehaviorGraphNotification( notificationName, stateName );
		
		
		if( notificationName == 'SpawnStart' )
		{
			RemoveTimer( 'UpdateIris' );
			StopEffect('drained_paint');
		}
		else if( notificationName == 'SpawnEnd' )
		{
			AddTimer( 'UpdateIris', 0.1, true );
		}		
	}
	
	
	private timer function UpdateIris( delta : float , id : int )
	{		
		UpdateHealthEffect();
		
		if( !m_TargetPainting || !m_TargetPainting.IsOpen() )
		{
			StopEffect( 'drained_paint' );
			m_TargetPainting = NULL;
		}
	}
	
	
	
	public function RequestPortal()
	{
		if( m_TargetPainting && m_TargetPainting.IsOpen() )
			return;
		
		m_TargetPainting = (W3IrisPainting) GetRandomPaintingAround();		
		m_TargetPainting.OpenPortal();
		
		SignalGameplayEvent('IrisPortalOpen');
		
		PlayEffect( 'drained_paint', m_TargetPainting);		
	}
	
	
	private function UpdateHealthEffect()
	{
		var l_healthPer 	: float;
		
		l_healthPer = GetHealthPercents();
		
		if( l_healthPer < 0 )
			return;
		
		if( m_CurrentHealthSection > 0 && l_healthPer < 0.25 )
		{	
			StopEffect( 'body_state01' );
			StopEffect( 'body_state02' );
			StopEffect( 'body_state03' );
			
			PlayEffect('body_state04', m_ClosestPainting);
			
			m_CurrentHealthSection = 0;
		}
		else if( m_CurrentHealthSection != 1 && l_healthPer >= 0.25 && l_healthPer < 0.5 )
		{
			StopEffect( 'body_state01' );
			StopEffect( 'body_state02' );
			StopEffect( 'body_state04' );
			PlayEffect('body_state03', m_ClosestPainting);
			
			m_CurrentHealthSection = 1;
		}
		else if( m_CurrentHealthSection != 2 && l_healthPer >= 0.5 && l_healthPer < 0.70 )
		{
			StopEffect( 'body_state01' );
			StopEffect( 'body_state04' );
			StopEffect( 'body_state03' );
			
			PlayEffect('body_state02', m_ClosestPainting);
			
			m_CurrentHealthSection = 2;
		}
		else if( m_CurrentHealthSection != 3 && l_healthPer >= 0.70  && l_healthPer < 0.9999 )
		{
			
			StopEffect( 'body_state04' );		
			StopEffect( 'body_state04' );
			StopEffect( 'body_state03' );
			StopEffect( 'body_state02' );
			
			PlayEffect('body_state01', m_ClosestPainting);
			
			m_CurrentHealthSection = 3;
		}	
	}
	
	
	
	public function GetClosestPainting( optional _CheckLineOfSight : bool ) : CNode
	{
		var l_delta 				: float;
		var l_availablePaintings	: array<CNode>;
		
		l_availablePaintings = GetAvailablePaintings( _CheckLineOfSight );
		
		SortNodesByDistance( GetWorldPosition(), l_availablePaintings );
		m_ClosestPainting = m_Paintings[0];	
		
		return m_ClosestPainting;
		
	}
	
	
	public function GetAvailablePaitingsQuantity() : int
	{
		var l_paintingsAround	: array<CNode>;
		l_paintingsAround = GetAvailablePaintings();
		return l_paintingsAround.Size();	
	}	
	
	
	
	public function GetAvailablePaintings( optional _CheckLineOfSight : bool ) : array<CNode>
	{
		var i					: int;
		var l_paintingsAround	: array<CNode>;
		var l_posToTest			: Vector;
		var l_matrix			: Matrix;
		var l_localOffset		: Vector;
		var l_hitPos			: Vector;
		var l_normal			: Vector;
		var l_currentPos		: Vector;
		
		l_paintingsAround 	= m_Paintings;
		l_localOffset	  	= Vector( 0, 1, 0);
		l_currentPos		= GetWorldPosition();
		
		for( i = l_paintingsAround.Size() - 1; i >= 0 ; i -= 1 )
		{
			l_matrix 	= l_paintingsAround[i].GetLocalToWorld();
			l_posToTest = VecTransform( l_matrix, l_localOffset);
			
			if ( ( _CheckLineOfSight && theGame.GetWorld().StaticTrace( l_currentPos, l_posToTest, l_hitPos, l_normal ) ) || AbsF( l_currentPos.Z - l_posToTest.Z ) > 5 )
			{
				l_paintingsAround.Erase( i );
			}
		}
		
		return l_paintingsAround;
	}
	
	
	public function GetRandomPaintingAround() : CNode
	{
		var l_paintingsAround	: array<CNode>;
		var l_rand				: int;
		
		l_paintingsAround = GetAvailablePaintings();
		
		SortNodesByDistance( thePlayer.GetWorldPosition(), l_paintingsAround );
		
		
		l_rand = RandRange( l_paintingsAround.Size() - 1 , Min( 1, l_paintingsAround.Size() - 1 ) );
		
		return l_paintingsAround[ l_rand ];
	}	
	
	
	event OnDeath( damageAction : W3DamageAction  )
	{
		((CEntity) m_ClosestPainting).StopEffect('ghost_appear');
		RemoveTimer( 'UpdateIris' );
		
		GetPortal().Close();
		
		super.OnDeath( damageAction );
	}
}