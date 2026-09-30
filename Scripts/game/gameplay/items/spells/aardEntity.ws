/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SAardEffects
{
	editable var baseCommonThrowEffect 				: name;
	editable var baseCommonThrowEffectUpgrade1		: name;
	editable var baseCommonThrowEffectUpgrade2		: name;
	editable var baseCommonThrowEffectUpgrade3		: name;

	editable var throwEffectSoil					: name;
	editable var throwEffectSoilUpgrade1			: name;
	editable var throwEffectSoilUpgrade2			: name;
	editable var throwEffectSoilUpgrade3			: name;
	
	editable var throwEffectSPNoUpgrade				: name;
	editable var throwEffectSPUpgrade1				: name;
	editable var throwEffectSPUpgrade2				: name;
	editable var throwEffectSPUpgrade3				: name;
	
	editable var throwEffectDmgNoUpgrade			: name;
	editable var throwEffectDmgUpgrade1				: name;
	editable var throwEffectDmgUpgrade2				: name;
	editable var throwEffectDmgUpgrade3				: name;
	
	editable var throwEffectWater 					: name;
	editable var throwEffectWaterUpgrade1			: name;
	editable var throwEffectWaterUpgrade2			: name;
	editable var throwEffectWaterUpgrade3			: name;
	
	editable var cameraShakeStrength				: float;
}

struct SAardAspect
{
	editable var projTemplate		: CEntityTemplate;
	editable var cone				: float;
	editable var distance			: float;
	editable var distanceUpgrade1	: float;
	editable var distanceUpgrade2	: float;
	editable var distanceUpgrade3	: float;
}

statemachine class W3AardEntity extends W3SignEntity
{
	editable var aspects		: array< SAardAspect >;
	editable var effects		: array< SAardEffects >;
	editable var waterTestOffsetZ : float;
	editable var waterTestDistancePerc : float;

	var disableRotationHack 		: bool;
	var projectileCollision 		: array< name >;
	
	default skillEnum = S_Magic_1;
	default waterTestOffsetZ = -2;
	default waterTestDistancePerc = 0.5;
	
		hint waterTestOffsetZ = "Z offset added to Aard Entity when testing for water level";
		hint waterTestDistancePerc = "Percentage of sign distance to use along heading for water test";		
		
	public function GetSignType() : ESignType
	{
		return ST_Aard;
	}
		
	event OnStarted()
	{
		if(IsAlternateCast())
		{
			
			
			if((CPlayer)owner.GetActor())
				GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
		}
		else
		{
			super.OnStarted();
		}
		
		projectileCollision.Clear();
		projectileCollision.PushBack( 'Projectile' );
		projectileCollision.PushBack( 'Door' );
		projectileCollision.PushBack( 'Static' );		
		projectileCollision.PushBack( 'Character' );
		projectileCollision.PushBack( 'ParticleCollider' ); 
		
		if ( owner.ChangeAspect( this, S_Magic_s01 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AardCircleCast' );
		}
		else
		{
			GotoState( 'AardConeCast' );
		}
	}

	
	event OnAardHit( sign : W3AardProjectile ) {}

	
	
	
	var processThrow_alternateCast : bool;
	
	protected function ProcessThrow( alternateCast : bool )
	{
		if ( owner.IsPlayer() )
		{
			
			ProcessThrow_MainTick( alternateCast );
		}
		else
		{
			processThrow_alternateCast = alternateCast;
			AddTimer( 'ProcessThrowTimer', 0.00000001f, , , TICK_Main );
		}
	}
	
	timer function ProcessThrowTimer( dt : float, id : int )
	{
		ProcessThrow_MainTick( processThrow_alternateCast );
	}
	
	
	
	public final function GetDistance() : float
	{
		if ( owner.CanUseSkill( S_Magic_s20 ) )
		{
			switch( owner.GetSkillLevel( S_Magic_s20 ) )
			{
				case 1 : return aspects[ fireMode ].distanceUpgrade1;
				case 2 : return aspects[ fireMode ].distanceUpgrade2;
				case 3 : return aspects[ fireMode ].distanceUpgrade3;
			}
		}
		
		return aspects[ fireMode ].distance;
	}
	
	protected function ProcessThrow_MainTick( alternateCast : bool )
	{
		var projectile	: W3AardProjectile;
		var spawnPos, collisionPos, collisionNormal, waterCollTestPos : Vector;
		var spawnRot : EulerAngles;
		var heading : Vector;
		var distance, waterZ, staminaDrain : float;
		var ownerActor : CActor;
		var dispersionLevel : int;
		var attackRange : CAIAttackRange;
		var movingAgent : CMovingPhysicalAgentComponent;
		var hitsWater : bool;
		var collisionGroupNames : array<name>;
		
		ownerActor = owner.GetActor();
		
		if ( owner.IsPlayer() )
		{
			GCameraShake(effects[fireMode].cameraShakeStrength, true, this.GetWorldPosition(), 30.0f);
		}
		
		
		distance = GetDistance();		
		
		if ( owner.HasCustomAttackRange() )
		{
			attackRange = theGame.GetAttackRangeForEntity( this, owner.GetCustomAttackRange() );
		}
		else if( owner.CanUseSkill( S_Magic_s20 ) )
		{
			dispersionLevel = owner.GetSkillLevel(S_Magic_s20);
			
			if(dispersionLevel == 1)
			{
				if ( !alternateCast )
					attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade1' );
				else
					attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade1' );
			}
			else if(dispersionLevel == 2)
			{
				if ( !alternateCast )
					attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade2' );
				else
					attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade2' );
			}
			else if(dispersionLevel == 3)
			{
				if ( !alternateCast )
					attackRange = theGame.GetAttackRangeForEntity( this, 'cone_upgrade3' );
				else
					attackRange = theGame.GetAttackRangeForEntity( this, 'blast_upgrade3' );
			}
		}
		else
		{
			if ( !alternateCast )
				attackRange = theGame.GetAttackRangeForEntity( this, 'cone' );
			else
				attackRange = theGame.GetAttackRangeForEntity( this, 'blast' );
		}
		
		
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		heading = this.GetHeadingVector();
		
		
		
		
		if ( alternateCast )
		{
			spawnPos.Z -= 0.5;
			
			projectile = (W3AardProjectile)theGame.CreateEntity( aspects[fireMode].projTemplate, spawnPos - heading * 0.7, spawnRot );				
			projectile.ExtInit( owner, skillEnum, this );	
			projectile.SetAttackRange( attackRange );
			projectile.SphereOverlapTest( distance, projectileCollision );			
		}
		else
		{			
			spawnPos -= 0.7 * heading;
			
			projectile = (W3AardProjectile)theGame.CreateEntity( aspects[fireMode].projTemplate, spawnPos, spawnRot );				
			projectile.ExtInit( owner, skillEnum, this );							
			projectile.SetAttackRange( attackRange );
			
			projectile.ShootCakeProjectileAtPosition( aspects[fireMode].cone, 3.5f, 0.0f, 30.0f, spawnPos + heading * distance, distance, projectileCollision );			
		}
		
		if(ownerActor.HasAbility('Glyphword 6 _Stats', true))
		{
			staminaDrain = CalculateAttributeValue(ownerActor.GetAttributeValue('glyphword6_stamina_drain_perc'));
			projectile.SetStaminaDrainPerc(staminaDrain);			
		}
		
		if(alternateCast)
		{
			movingAgent = (CMovingPhysicalAgentComponent)ownerActor.GetMovingAgentComponent();
			hitsWater = movingAgent.GetSubmergeDepth() < 0;
		}
		else
		{
			waterCollTestPos = GetWorldPosition() + heading * distance * waterTestDistancePerc;			
			waterCollTestPos.Z += waterTestOffsetZ;
			collisionGroupNames.PushBack('Terrain');
			
			
			waterZ = theGame.GetWorld().GetWaterLevel(waterCollTestPos, true);
			
			
			if(theGame.GetWorld().StaticTrace(GetWorldPosition(), waterCollTestPos, collisionPos, collisionNormal, collisionGroupNames))
			{
				
				if(waterZ > collisionPos.Z && waterZ > waterCollTestPos.Z)
					hitsWater = true;
				else
					hitsWater = false;
			}
			else
			{
				
				hitsWater = (waterCollTestPos.Z <= waterZ);
			}
		}
		
		PlayAardFX(hitsWater);
		ownerActor.OnSignCastPerformed(ST_Aard, alternateCast);
		AddTimer('DelayedDestroyTimer', 0.1, true, , , true);
	}
	
	
	public final function PlayAardFX(hitsWater : bool)
	{
		var dispersionLevel : int;
		var hasMutation6 : bool;
		
		hasMutation6 = owner.GetPlayer().IsMutationActive(EPMT_Mutation6);
		
		if ( owner.CanUseSkill( S_Magic_s20 ) )
		{
			
			PlayEffect( effects[fireMode].baseCommonThrowEffect );
		
			
			if(!hasMutation6)
			{
				if(hitsWater)
					PlayEffect( effects[fireMode].throwEffectWater );
				else
					PlayEffect( effects[fireMode].throwEffectSoil );
			}

			
			
		}
		else
		{
			
			PlayEffect( effects[fireMode].baseCommonThrowEffect );
		
			
			if(!hasMutation6)
			{
				if(hitsWater)
					PlayEffect( effects[fireMode].throwEffectWater );
				else
					PlayEffect( effects[fireMode].throwEffectSoil );
			}
		}
		
		
		if(owner.CanUseSkill(S_Magic_s12))
		{
			
			switch(dispersionLevel)
			{
				case 0:
					PlayEffect( effects[fireMode].throwEffectSPNoUpgrade );
					break;
				case 1:
					PlayEffect( effects[fireMode].throwEffectSPUpgrade1 );
					break;
				case 2:
					PlayEffect( effects[fireMode].throwEffectSPUpgrade2 );
					break;
				case 3:
					PlayEffect( effects[fireMode].throwEffectSPUpgrade3 );
					break;
			}
		}
		
		
		if(owner.CanUseSkill(S_Magic_s06) || owner.CanUseSkill(S_Magic_s33))
		{
			
			switch(dispersionLevel)
			{
				case 0:
					PlayEffect( effects[fireMode].throwEffectDmgNoUpgrade );
					break;
				case 1:
					PlayEffect( effects[fireMode].throwEffectDmgUpgrade1 );
					break;
				case 2:
					PlayEffect( effects[fireMode].throwEffectDmgUpgrade2 );
					break;
				case 3:
					PlayEffect( effects[fireMode].throwEffectDmgUpgrade3 );
					break;
			}
		}
		
		
		if( hasMutation6 )
		{
			thePlayer.PlayEffect( 'mutation_6_power' );
			
			if( fireMode == 0 )
			{
				PlayEffect( 'cone_ground_mutation_6' );
			}
			else
			{
				PlayEffect( 'blast_ground_mutation_6' );
				
				theGame.GetSurfacePostFX().AddSurfacePostFXGroup(GetWorldPosition(), 0.3f, 3.f, 2.f, GetDistance(), 0 );
			}
		}
	}
	
	timer function DelayedDestroyTimer(dt : float, id : int)
	{
		var active : bool;
		
		active = IsEffectActive( effects[fireMode].baseCommonThrowEffect );
		
		if(!active)
			Destroy();
	}

	public function DisableRotationHack( disable : bool )
	{
		disableRotationHack = disable;
	}
}

state AardConeCast in W3AardEntity extends NormalCast
{		
	event OnThrowing()
	{
		var player				: CR4Player;
	
		if( super.OnThrowing() )
		{
			parent.ProcessThrow( false );
			
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
}

state AardCircleCast in W3AardEntity extends NormalCast
{
	event OnThrowing()
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		if( super.OnThrowing() )
		{
			parent.ProcessThrow( true );
			
			player = caster.GetPlayer();
			if(player == caster.GetActor() && player && player.CanUseSkill(S_Perk_09))
			{
				cost = player.GetStaminaActionCost(ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0);
				stamina = player.GetStat(BCS_Stamina, true);
				
				if(cost > stamina)
					player.DrainFocus(1);
				else
					caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
			else if ( player == caster.GetActor() && player && player.CanUseSkill( S_Perk_34 ) )	
			{
				cost = player.GetStaminaActionCost(ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0);
				stamina = player.GetStat(BCS_Stamina, true);
				
				if ( player.GetStatMax(BCS_Stamina) > stamina )
					player.DrainFocus( player.GetSignAdrenalineCostPerk34() );
				else
					caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
			}
			else
				caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
}