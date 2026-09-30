/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3ThrowingKnife extends W3Petard
{
	editable var spawnEntityTemplate 	: CEntityTemplate;
	editable var knifeThrowSpeed		: float;
	editable var slomoStrength			: float;
	editable var knifeThrowDelay		: float;
	var speedMultCasuserIdKnife			: int;
	var inWater							: bool;
	
	default inWater = false;
	default knifeThrowSpeed = 75.0f;
	default slomoStrength = 0.7f;
	default knifeThrowDelay = 0.5f;
	
	
	public function ThrowProjectile( targetPosIn : Vector )
	{		
		var phantom : CPhantomComponent;
		var inv : CInventoryComponent;
			
		
		phantom = (CPhantomComponent)GetComponent('snappingCollisionGroupNames');
		if(phantom)
		{
			phantom.GetTriggeringCollisionGroupNames(snapCollisionGroupNames);
		}
		else
		{
			snapCollisionGroupNames.PushBack('Terrain');
			snapCollisionGroupNames.PushBack('Static');
		}
		
		
		LoadDataFromItemXMLStats();		
	
		targetPos = targetPosIn;
		
		isProximity = false;
		
		theGame.RemoveTimeScale( theGame.GetTimescaleSource(ETS_ThrowingAim) );
		thePlayer.ResetAnimationSpeedMultiplier( speedMultCasuserIdKnife );
		
		
		AddTimer( 'ReleaseKnifeProjectile', 0.001, false, , , true );
		
		
		if ( GetOwner() != thePlayer )
		{
			inv = GetOwner().GetInventory();
			if(inv)
				inv.RemoveItem( itemId );
		}
		else
		{
			
			if(!FactsDoesExist("debug_fact_inf_bombs"))
				thePlayer.inv.SingletonItemRemoveAmmo(itemId, 1);
				
			
			if( thePlayer.inv.GetItemQuantity(itemId) < 1 )		
				thePlayer.ClearSelectedItemId();
			
			
			
			else if( !GetWitcherPlayer().IsSetBonusActive( EISB_RedWolf_1 ) )
			
			{
				GetWitcherPlayer().AddBombThrowDelay(itemId);
			}
				
			if(GetOwner() == GetWitcherPlayer())
				GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		}
	}
	
	
	timer function ReleaseKnifeProjectile( time : float , id : int)
	{
		var distanceToTarget, projectileFlightTime : float;
		var target : CActor = thePlayer.GetTarget();
		var actorsInAoE : array<CActor>;
		var i : int;
		var collisionGroups : array<name>;
		BreakAttachment();
		if( target.HasTag('AddRagdollCollision'))
		{
			collisionGroups.PushBack('Ragdoll');
			collisionGroups.PushBack('Terrain');
			collisionGroups.PushBack('Static');
			collisionGroups.PushBack('Water');
			collisionGroups.PushBack('Destructible');			
			ShootProjectileAtPosition( 0.0f, knifeThrowSpeed, targetPos, theGame.params.MAX_THROW_RANGE, collisionGroups);
		}
		else
		{
			ShootProjectileAtPosition( 0.0f, knifeThrowSpeed, targetPos, theGame.params.MAX_THROW_RANGE );
		}
		
		if(isFromAimThrow && ShouldProcessTutorial('TutorialThrowHold'))
		{
			wasInTutorialTrigger = (FactsQuerySum("tut_aim_in_trigger") > 0);				
		}
		
		actorsInAoE = thePlayer.playerAiming.GetSweptActors();
		
		if ( actorsInAoE.Size() > 0 )
		{
			if( dodgeable )
			{
				for ( i=0 ; i < actorsInAoE.Size() ; i+=1 )
				{
					actorsInAoE[i].SignalGameplayEvent( 'Time2DodgeBombAOE' );
					((CNewNPC)actorsInAoE[i]).OnIncomingProjectile( true );
				}
			}
		}
		else if( target )
		{	
			if( dodgeable )
			{
				distanceToTarget = VecDistance( thePlayer.GetWorldPosition(), target.GetWorldPosition() );	
				
				
				projectileFlightTime = distanceToTarget / 15;
				target.SignalGameplayEventParamFloat( 'Time2DodgeBomb', projectileFlightTime );
			}
			
			((CNewNPC)target).OnIncomingProjectile( true );
		}
		
		if ( enableTrailFX )
		{
			PlayEffectSingle(FX_TRAIL);
		}
		wasThrown = true;
		
		
		
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var hitNpc : CNewNPC;
		var hitVictim : CActor;
		var hitEntity : CEntity;
		
		if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			inWater = true;
		}
		
		if ( (hitCollisionsGroups.Contains( 'Terrain' ) || hitCollisionsGroups.Contains( 'Static' )) && !inWater)
		{
			if( collidingComponent )
			{
				hitEntity = collidingComponent.GetEntity();
				hitVictim = (CActor)hitEntity;
				hitNpc = (CNewNPC)(hitVictim);
			
				if( hitEntity == GetOwner())
					return true;
				else if ( hitEntity && !hitNpc )
				{
					SpawnEntity( false );
				}
			}
			else
			{
				ProjectileHitGround();
			}
		}
		
		
		super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
		
	}
	
	protected function ProjectileHitGround()
	{
		SpawnEntity( true );
	}
	
	function SpawnEntity( onGround : bool )
	{
		var ent : CEntity;
		var entPos, normal : Vector;
		
		if ( spawnEntityTemplate )
		{
			entPos = this.GetWorldPosition();
			if ( onGround )
				theGame.GetWorld().StaticTrace( entPos + Vector(0,0,3), entPos - Vector(0,0,3), entPos, normal );
			ent = theGame.CreateEntity( spawnEntityTemplate, entPos + Vector(0,-0.3f,0), this.GetWorldRotation() );
		}
	}
	public function SetMultCasuser ( multValue : int )
	{
		speedMultCasuserIdKnife = multValue;
	}
}