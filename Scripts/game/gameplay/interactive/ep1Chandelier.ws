/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class EP1Chandelier extends CGameplayEntity
{
	editable var m_fallSpeed : float;
	editable var m_damagePercent : float;
	editable var m_fallDelay : float;
	
	var m_floorLevel : float;
	var m_radius : float;
	var m_height : float;
	var m_falling : bool;
	var m_currTime : float;
	
	default m_fallSpeed = 1.0f;
	default m_falling = false;
	default m_damagePercent = 0.1f;
	default m_fallDelay = 1.0f;

	timer function UpdatePreFalling( dt : float, id : int )
	{
		var chains : CEntity;
		var chainsAnim : CAnimatedComponent;
		
		m_currTime += dt;
		if( m_currTime >= m_fallDelay )
		{
			
			
			
				
				
				
				
				
			
			
			SoundEvent( 'q604_chandelier_chain_break' );
			AddTimer( 'UpdateFalling', 0.00001f, true );
			RemoveTimer( 'UpdatePreFalling' );
		}
	}

	timer function UpdateFalling( dt : float, id : int )
	{
		var pos : Vector;
		
		pos = GetWorldPosition();
		
		if( !CheckCollision( pos ) )
		{
			pos.Z -= m_fallSpeed * dt;		
			if( !CheckCollision( pos ) )
			{
				Teleport( pos );
			}
		}
	}
	
	function CheckCollision( pos : Vector ) : bool
	{
		var collision : bool;

		collision = false;
		if( CheckPlayerCollision( pos ) )
		{
			HitPlayer();
			collision = true;
		}
		
		if( collision || CheckFloorCollision( pos ) )
		{
			Fracture();
			RemoveTimer( 'UpdateFalling' );
			PlayEffect( 'dust_crash' );
			SoundEvent( 'q604_chandelier_fall' );
			FactsAdd( "q604_chandelier_fallen", 1, -1 );
			return true;
		}
		
		return false;
	}
	
	function CheckFloorCollision( pos : Vector ) : bool
	{
		return ( pos.Z < m_floorLevel );
	}
	
	function CheckPlayerCollision( pos : Vector ) : bool
	{
		var ppos : Vector;
		var playerBBox : Box;
		var minDist2 : float;
		var halfHeight : float;
		
		ppos = thePlayer.GetWorldPosition();
		thePlayer.CalcBoundingBox( playerBBox );
		halfHeight = m_height / 2.0f;
		
		if( ( ( pos.Z - halfHeight ) > playerBBox.Max.Z ) || ( ( pos.Z + halfHeight ) < playerBBox.Min.Z ) )
		{
			return false;
		}
		
		minDist2 = m_radius * m_radius;
		return ( VecDistanceSquared2D( pos, ppos ) < minDist2 );
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( m_falling || ( thePlayer != ( CR4Player )activator.GetEntity() ) )
		{
			return false;
		}
		
		if ( FactsDoesExist( 'q604_chandelier_fallen' ) )
		{
			return false;
		}

		CalcChandelierSetup();
		CalcGroundLevel();

		m_currTime = 0.0f;
		m_falling = true;
		
		PlayEffect( 'dust' );
		SoundEvent( 'q604_chandelier_prefall' );
		AddTimer( 'UpdatePreFalling', 0.00001f, true );
	}
	
	function CalcGroundLevel()
	{
		var traceStartPos, traceEndPos, traceEffect, normal : Vector;
		
		traceStartPos = GetWorldPosition();
		traceEndPos = traceStartPos;
		traceStartPos.Z -= 0.5f;
		traceEndPos.Z -= 10.0f;

		if( theGame.GetWorld().StaticTrace( traceStartPos, traceEndPos, traceEffect, normal ) )
		{
			m_floorLevel = traceEffect.Z + 0.2f;
		}
	}
	
	function CalcChandelierSetup()
	{
		var activator : CTriggerActivatorComponent;

		activator = ( CTriggerActivatorComponent )GetComponentByClassName( 'CTriggerActivatorComponent' );
		if( !activator )
		{
			return;
		}
		
		m_radius = activator.GetRadius();
		m_height = activator.GetHeight();
	}
	
	function Fracture()
	{
		var i : int;
		var c : array< CComponent >;
		var destructable : CDestructionComponent;

		c = GetComponentsByClassName( 'CDestructionComponent' );
		for( i = 0; i < c.Size() ; i += 1 )
		{
			destructable = ( CDestructionComponent )c[ i ];
			if( destructable )
			{
				destructable.ApplyFracture();
			}
		}
	}
	
	function HitPlayer()
	{
		var action : W3DamageAction;

		action = new W3DamageAction in theGame.damageMgr;
		action.Initialize( NULL, thePlayer, NULL, 'chandelier', EHRT_Light, CPS_Undefined, false, false, false, false );
		action.AddDamage( theGame.params.DAMAGE_NAME_DIRECT, thePlayer.GetStatMax( BCS_Vitality ) * m_damagePercent );
		action.SetSuppressHitSounds( true );
		action.SetHitAnimationPlayType( EAHA_ForceYes );
		theGame.damageMgr.ProcessAction(action);
		delete action;
	}
}
