/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageSplashEffect extends IBehTreeTask
{
	
	
	
	private var m_SplashEntityTemplate 			: CEntityTemplate;
	private var m_PreviousDistanceFromSurface 	: float;
	
	private var m_CrossedOnce					: bool;
	
	private var couldntLoadResource : bool;
	
	
	
	function IsAvailable() : bool
	{
		if ( couldntLoadResource )
		{
			return false;
		}
		return true;
	}
	
	latent function Main() : EBTNodeStatus
	{	
		var l_distanceFromSurface 	: float;
		var l_waterDepth 			: float;
		var l_pos					: Vector;
		
		if ( !m_SplashEntityTemplate )
			m_SplashEntityTemplate = (CEntityTemplate) LoadResourceAsync('water_splashes');
		
		if ( !m_SplashEntityTemplate )
		{
			couldntLoadResource = true;
			return BTNS_Failed;
		}
		
		l_pos = GetNPC().GetWorldPosition();
		
		l_waterDepth = theGame.GetWorld().GetWaterDepth( l_pos );
		if( l_waterDepth > 1000 ) l_waterDepth = 0;
		
		if( l_waterDepth < 1 ) m_CrossedOnce = true;
		
		while( GetNPC().IsAlive() || !m_CrossedOnce )
		{		
			l_distanceFromSurface = DistanceFromWaterSurface();
			
			
			
			if( m_PreviousDistanceFromSurface != 0 && l_distanceFromSurface * m_PreviousDistanceFromSurface < 0 )
			{
				SpawnWaterSplash();
				m_CrossedOnce = true;
			}
			
			
			if( !GetNPC().IsAlive() && l_distanceFromSurface < 0 )
			{				
				m_CrossedOnce = true;
			}
			
			m_PreviousDistanceFromSurface = DistanceFromWaterSurface();
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	
	function DistanceFromWaterSurface() : float
	{
		var l_position 		: Vector;
		var l_world 		: CWorld;
		var l_waterLevel 	: float;
		
		l_world 		= theGame.GetWorld();		
		l_position 		= GetNPC().GetWorldPosition();		
		l_waterLevel 	= l_world.GetWaterLevel( l_position );		
		
		return ( l_position.Z - l_waterLevel );
	}
	
	
	private function SpawnWaterSplash( )
	{
		var l_splashPosition 	: Vector;
		var l_splastEntity		: CEntity;
		
		l_splashPosition 	= GetNPC().GetWorldPosition();
		l_splashPosition.Z 	= theGame.GetWorld().GetWaterLevel( l_splashPosition ) - 0.1;
		
		l_splastEntity = theGame.CreateEntity( m_SplashEntityTemplate, l_splashPosition, GetNPC().GetWorldRotation());
		
		
		
	}

}




class BTTaskManageSplashEffectDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageSplashEffect';
}