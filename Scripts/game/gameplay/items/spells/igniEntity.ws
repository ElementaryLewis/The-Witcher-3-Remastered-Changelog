/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SIgniEffects
{
	editable var throwEffect	: name;
	editable var forestEffect	: name;
	editable var upgradedThrowEffect : name;
	editable var meltArmorEffect : name;		
	editable var combustibleEffect : name;		
	editable var throwEffectSpellPower : name;		
}

struct SIgniAspect
{
	editable var projTemplate		: CEntityTemplate;
	editable var cone				: float;
	editable var distance			: float;
	editable var upgradedDistance 	: float;
}

struct SIgniChannelDT
{
	var actor : CActor;
	var dtSinceLastTest : float;
};

statemachine class W3IgniEntity extends W3SignEntity
{
	
	protected var burnEffectPlayed : bool;
	public function GetBurnEffectPlayed() : bool
	{
		return burnEffectPlayed;
	}
	

	private var collisionFxEntity, rangeFxEntity	: CEntity;				
	private var channelBurnTestDT : array<SIgniChannelDT>;					
	private var lastCollisionFxPos : Vector;								
	
	private const var CHANNELLING_BURN_TEST_FREQUENCY : float;		
	
		default CHANNELLING_BURN_TEST_FREQUENCY = 0.2;

	
	editable var aspects			: array< SIgniAspect >;

	editable var effects			: array< SIgniEffects >;
	
	
	private var forestTrigger		: W3ForestTrigger;
			
	default skillEnum = S_Magic_2;

	var projectileCollision 		: array< name >;
	
	
	var hitEntities					: array< CGameplayEntity >;
	
	public 	  var lastFxSpawnTime : float;
	
	public function GetSignType() : ESignType
	{
		return ST_Igni;
	}
		
	event OnStarted()
	{
		var player : CR4Player;
		
		Attach( true );
		
		channelBurnTestDT.Clear();
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
		
		projectileCollision.Clear();
		projectileCollision.PushBack( 'Projectile' );
		projectileCollision.PushBack( 'Door' );
		projectileCollision.PushBack( 'Static' );		
		projectileCollision.PushBack( 'Character' );
		projectileCollision.PushBack( 'Terrain' );
		projectileCollision.PushBack( 'Ragdoll' );
		projectileCollision.PushBack( 'Destructible' );
		projectileCollision.PushBack( 'RigidBody' );
		projectileCollision.PushBack( 'Dangles' );
		projectileCollision.PushBack( 'Water' );
		projectileCollision.PushBack( 'Projectile' );
		projectileCollision.PushBack( 'Foliage' );
		projectileCollision.PushBack( 'Boat' );
		projectileCollision.PushBack( 'BoatDocking' );
		projectileCollision.PushBack( 'Platforms' );
		projectileCollision.PushBack( 'Corpse' );
		projectileCollision.PushBack( 'ParticleCollider' ); 
	
		if ( owner.ChangeAspect( this, S_Magic_s02 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'IgniChanneled' );
		}
		else
		{
			if(owner.GetActor().HasAbility('Glyphword 7 _Stats', true))
				fireMode = 2;
				
			GotoState( 'IgniCast' );
		}
	}
	
	protected function FillActionBuffsFromSkill(act : W3DamageAction)
	{
		
		
		
		
		super.FillActionBuffsFromSkill(act);
	}
	
	
	
	public function UpdateBurningChance(actor : CActor, dt : float) : bool
	{
		var i, j : int;
		var temp : SIgniChannelDT;
		
		if(!actor)
			return false;
			
		i = -1;
		for(j=0; j<channelBurnTestDT.Size(); j+=1)
		{
			if(channelBurnTestDT[j].actor == actor)
			{
				i = j;
				break;
			}
		}
		
		if(i >= 0)
		{
			channelBurnTestDT[i].dtSinceLastTest += dt;
		}
		else
		{
			temp.actor = actor;
			temp.dtSinceLastTest = dt;
			channelBurnTestDT.PushBack(temp);
			i = channelBurnTestDT.Size() - 1;
		}
		
		if(channelBurnTestDT[i].dtSinceLastTest >= CHANNELLING_BURN_TEST_FREQUENCY)
		{
			channelBurnTestDT[i].dtSinceLastTest -= CHANNELLING_BURN_TEST_FREQUENCY;
			return true;
		}
			
		return false;
	}
	
	protected function InitThrown()
	{
		var entity : CEntity;
		
		entity = theGame.GetEntityByTag( 'forest' );		
		if(entity)
			forestTrigger = (W3ForestTrigger)entity;
				
		if(false)
		{
			PlayEffect( effects[fireMode].upgradedThrowEffect );
		}
		else
		{
			if(!IsAlternateCast() && owner.CanUseSkill(S_Magic_s07))
			{
				PlayEffect( effects[fireMode].throwEffect ); 
				PlayEffect( effects[fireMode].throwEffectSpellPower );				
			}
			else
			{
				PlayEffect( effects[fireMode].throwEffect );
			}
		}
			
		
		if(!IsAlternateCast())
		{
			
			if(owner.CanUseSkill(S_Magic_s08))
				PlayEffect(effects[0].meltArmorEffect);
			
			
			if(owner.CanUseSkill(S_Magic_s09))
				PlayEffect(effects[0].combustibleEffect);
		}
		
		if( owner.IsPlayer() && forestTrigger && forestTrigger.IsPlayerInForest() )
		{
			PlayEffect( effects[fireMode].forestEffect );
		}
	}
	
	function BroadcastSignCast_Override()
	{
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'FireDanger', 5, 8.0f, -1.f, -1, true, true );
	}
		
	
	public function ShowChannelingCollisionFx(pos : Vector, rot : EulerAngles, normall : Vector)
	{
		var collisionFxTemplate : CEntityTemplate;
		var coll, normal : Vector;
		
		
		
		if(VecDistance(lastCollisionFxPos, pos) > 0.35)
		{
			lastCollisionFxPos = pos;
			
			if(theGame.GetWorld().StaticTrace(GetWorldPosition(), pos, coll, normal))
			{
				
				pos = coll;
			}
			
			
			pos = pos + normall * 0.1;
		
			if(!collisionFxEntity)
			{			
				collisionFxTemplate = (CEntityTemplate)LoadResource("gameplay\sign\igni_channeling_collision_fx");
				collisionFxEntity = theGame.CreateEntity(collisionFxTemplate, pos, rot);
			}
			else
			{
				collisionFxEntity.TeleportWithRotation(pos, rot);
			}
		}
		
		AddTimer('CollisionFXTimedOutDestroy', 0.3, , , , true);
	}
	
	public function ShowChannelingRangeFx(pos : Vector, rot : EulerAngles)
	{
		var rangeFxTemplate : CEntityTemplate;
	
		if(!rangeFxEntity)
		{			
			rangeFxTemplate = (CEntityTemplate)LoadResource("gameplay\sign\igni_channeling_range_fx");
			rangeFxEntity = theGame.CreateEntity(rangeFxTemplate, pos, rot);
		}
		else
		{
			rangeFxEntity.TeleportWithRotation(pos, rot);
		}
		
		AddTimer('RangeFXTimedOutDestroy', 0.1, , , , true);
	}
	
	protected function CleanUp()
	{
		hitEntities.Clear();
		super.CleanUp();
	}
	
	
	timer function CollisionFXTimedOutDestroy(dt : float, id : int)
	{
		if(collisionFxEntity)
			collisionFxEntity.AddTimer('TimerStopVisualFX', 0.001, , , , true);
	}
	
	
	timer function RangeFXTimedOutDestroy(dt : float, id : int)
	{
		if(rangeFxEntity)
			rangeFxEntity.AddTimer('TimerStopVisualFX', 0.001, , , , true);
	}
}

state IgniCast in W3IgniEntity extends NormalCast
{
	event OnThrowing()
	{
		var player			: CR4Player;
		
		if( super.OnThrowing() )
		{
			parent.InitThrown();
			
			ProcessThrow();
			
			player = caster.GetPlayer();
			
			if( player )
			{
				parent.ManagePlayerStamina();
				parent.ManageGryphonSetBonusBuff();
			}
			else 
			{
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
		}
	}
	
	private function ProcessThrow()
	{
		var projectile	: W3SignProjectile;
		var spawnPos, heading: Vector;
		var spawnRot : EulerAngles;		
		var attackRange : CAIAttackRange;
		var distance : float;
		var castDir	: Vector;
		var castDirEuler : EulerAngles;
		var casterActor : CActor;		
		var dist, aspectDist : float;
		var angle : float;

		
		spawnPos = parent.GetWorldPosition();
		spawnRot = parent.GetWorldRotation();		
		heading = parent.owner.GetActor().GetHeadingVector();
		casterActor = caster.GetActor();

		
		
		
		projectile = (W3SignProjectile)theGame.CreateEntity( parent.aspects[parent.fireMode].projTemplate, spawnPos - heading * 0.7f, spawnRot );
		projectile.ExtInit( caster, parent.skillEnum, parent );
		
		parent.PlayEffect( projectile.projData.flyEffect );
		
		distance = parent.aspects[parent.fireMode].distance;
		
		if ( caster.HasCustomAttackRange() )
			attackRange = theGame.GetAttackRangeForEntity( parent, caster.GetCustomAttackRange() );
		else if(parent.fireMode == 2)
			attackRange = theGame.GetAttackRangeForEntity( parent, 'cylinder' );
		else
			attackRange = theGame.GetAttackRangeForEntity( parent, 'cone' );
		
		projectile.SetAttackRange( attackRange );
		
		if(parent.fireMode == 2)
			projectile.SphereOverlapTest(distance, parent.projectileCollision);		
		else
			projectile.ShootCakeProjectileAtPosition( parent.aspects[parent.fireMode].cone, 3.5f, 0.0f, 30.0f, spawnPos + heading * distance, distance, parent.projectileCollision );		
		
		
		aspectDist 		= parent.aspects[parent.fireMode].distance;
		castDir 		= MatrixGetAxisX( casterActor.GetBoneWorldMatrixByIndex( parent.boneIndex ) );
		castDirEuler 	= VecToRotation( castDir );
		dist = aspectDist * ( 1.f - caster.GetHandAimPitch() * 0.75f );
		angle = 45.0 + ( caster.GetHandAimPitch() * 45.f );
		Boids_CastFireInCone( casterActor.GetWorldPosition(), castDirEuler.Yaw, angle, dist );	
		
		casterActor.OnSignCastPerformed(ST_Igni, false);
	}
	
	event OnEnded(optional isEnd : bool)
	{
		parent.CleanUp();
		
		super.OnEnded(isEnd);
	}
	
	event OnSignAborted( optional force : bool )
	{		
		parent.CleanUp();
		
		super.OnSignAborted( force );
	}
}

state IgniChanneled in W3IgniEntity extends Channeling
{
	var reusableProjectiles : array< W3IgniProjectile >;
		
	function GetReusableProjectile( spawnPos : Vector, spawnRot : EulerAngles, dt : float ) : W3IgniProjectile
	{
		var i, size : int;
		var projectile : W3IgniProjectile;
		var unusedProjectile : W3IgniProjectile;
		var emptyIndex : int;
		
		emptyIndex = -1;
		size = reusableProjectiles.Size();
		for ( i = 0; i < size; i+=1 )
		{
			projectile = reusableProjectiles[i];
			if ( !projectile )
			{
				if ( emptyIndex == -1 )
				{
					emptyIndex = i;
				}
			}
			else if ( !projectile.IsUsed() || projectile.IsStopped() )
			{			
				unusedProjectile = projectile;
				unusedProjectile.StopProjectile();
				unusedProjectile.ClearHitEntities();
				unusedProjectile.TeleportWithRotation( spawnPos, spawnRot );
				break;
			}
		}
		
		if ( !unusedProjectile )
		{
			unusedProjectile = (W3IgniProjectile)theGame.CreateEntity( parent.aspects[parent.fireMode].projTemplate, spawnPos, spawnRot );
			unusedProjectile.ExtInit( caster, parent.skillEnum, parent, true );
			if ( emptyIndex != -1 )
			{
				reusableProjectiles[ emptyIndex ] = unusedProjectile;
			}
			else
			{				
				reusableProjectiles.PushBack( unusedProjectile );
			}
		}	

		unusedProjectile.SetIsUsed( true );
		unusedProjectile.SetDT( dt );		
				
		return projectile;
	}

	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
				
		caster.OnDelayOrientationChange();
	}
	
	event OnThrowing()
	{
		if ( super.OnThrowing() )
		{
			parent.InitThrown();
			
			ChannelIgni();
		}
	}
	
	event OnEnded(optional isEnd : bool)
	{
		super.OnEnded(isEnd);
		
		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
			caster.GetPlayer().ResetRawPlayerHeading();		
		}		
		
		parent.AddTimer('RangeFXTimedOutDestroy', 0.1, , , , true);
		parent.AddTimer('CollisionFXTimedOutDestroy', 0.3, , , , true);
		
		CleanUp();
		
		if ( false )
		{
			parent.StopEffect( parent.effects[parent.fireMode].upgradedThrowEffect );
		}
		else
		{
			parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
			parent.StopEffect( parent.effects[parent.fireMode].throwEffectSpellPower );			
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
		
		parent.AddTimer('RangeFXTimedOutDestroy', 0.1, , , , true);
		parent.AddTimer('CollisionFXTimedOutDestroy', 0.3, , , , true);
		
		CleanUp();
		
		super.OnSignAborted( force );
	}	
	
	entry function ChannelIgni()
	{
		var lastTime, currTime : float;
		
		lastTime = -1;
		caster.GetActor().OnSignCastPerformed(ST_Igni, true);
		while( Update() )
		{
			currTime = theGame.GetEngineTimeAsSeconds();
			if(lastTime == -1)
				lastTime = currTime;	
			
			if(currTime - lastTime > 0)	
				ProcessThrow(currTime - lastTime);
				
			lastTime = currTime;	
	
			
			if(parent.IsEffectActive('burn', false) || parent.IsEffectActive('burn_upgrade', false))
				parent.burnEffectPlayed = true;
			
		
			SleepOneFrame();
		}
	}
	
	function CleanUp()
	{
		var i, size : int;
		
		size = reusableProjectiles.Size();
		for ( i = 0; i < size; i+=1 )
		{
			if ( reusableProjectiles[i] )
			{
				reusableProjectiles[i].Destroy();
			}		
		}
		reusableProjectiles.Clear();
		
		parent.CleanUp();
	}
	
	private function ProcessThrow(dt : float)
	{
		var projectile	: W3IgniProjectile;
		var dist, aspectDist : float;
		var angle : float;
		var spawnPos : Vector;
		var spawnRot : EulerAngles;
		var targetPosition : Vector;
		var combatTargetPosition : Vector;
		var castDir	: Vector;
		var castDirEuler : EulerAngles;
		var casterActor : CActor;		
		var attackRange : CAIAttackRange;
		
		casterActor = caster.GetActor();
		
		
		spawnPos = parent.GetWorldPosition();
		spawnRot = parent.GetWorldRotation();
		
		
		
		
		projectile = GetReusableProjectile( spawnPos - 0.7 * casterActor.GetHeadingVector(), spawnRot, dt );
		
		if(true)
			aspectDist 		= parent.aspects[parent.fireMode].distance;
		else
			aspectDist 		= parent.aspects[parent.fireMode].upgradedDistance;		
			
		castDir 		= MatrixGetAxisX( casterActor.GetBoneWorldMatrixByIndex( parent.boneIndex ) );
		castDirEuler 	= VecToRotation( castDir );
		
		targetPosition = spawnPos + ( aspectDist * castDir );
		if ( casterActor.IsInCombat() )
		{
			combatTargetPosition = casterActor.GetTarget().GetWorldPosition();
			targetPosition.Z = combatTargetPosition.Z + 1;			
		}
		
		if ( caster.HasCustomAttackRange() )
		{
			attackRange = theGame.GetAttackRangeForEntity( parent, caster.GetCustomAttackRange() );
		}
		else if (false)
		{
			attackRange = theGame.GetAttackRangeForEntity( parent, 'burn_upgraded' );
		}
		else
		{
			attackRange = theGame.GetAttackRangeForEntity( parent, 'burn' );
		}		
		
		projectile.SetAttackRange( attackRange );
		projectile.ShootProjectileAtPosition( 0, 10, targetPosition, aspectDist, parent.projectileCollision );
		
		dist = aspectDist * ( 1.f - caster.GetHandAimPitch() * 0.75f );
		angle = 45.0 + ( caster.GetHandAimPitch() * 45.f );
		Boids_CastFireInCone( casterActor.GetWorldPosition(), castDirEuler.Yaw, angle, dist );		
	}
}
