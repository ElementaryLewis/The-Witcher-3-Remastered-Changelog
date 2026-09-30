/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Petard extends CThrowable
{
	
	protected editable var cameraShakeStrMin 				: float;
	protected editable var cameraShakeStrMax 				: float;
	protected editable var cameraShakeRange 				: float;
	protected editable var hitReactionType 					: EHitReactionType;
	protected editable var noLoopEffectIfHitWater			: bool;
	protected editable var dismemberOnKill 					: bool;
	protected editable var componentsEnabledOnLoop 			: array<name>;
	protected editable var friendlyFire						: bool;
	protected editable var impactParams						: SPetardParams;
	protected editable var loopParams						: SPetardParams;
	protected editable var dodgeable						: bool;
	protected editable var audioImpactName					: name;
	protected editable var ignoreBombSkills					: bool;
	protected editable var enableTrailFX 					: bool;
	protected editable var alignToNormal					: bool;
	
		hint initialBlastRadius = "Radius in which targets are collected when petard explodes";
		hint loopEffectRadius = "Radius for the lasting effect";
		hint cameraShakeRange = "Max range at which camera shake will occur";
		hint cameraShakeStrMin = "Min strength of camera shake (at max distance from center)";
		hint cameraShakeStrMax = "Max strength of camera shake (at the center of explosion)";
		hint hitReactionType = "Type of hit animation to play on target when hit by bomb. Ignored if Knockdown/Stagger used";
		hint noLoopEffectIfHitWater = "If petard hit water then there will be no loop effect or FX";
		hint dismemberOnKill = "If set then if Actor is killed by this petard it will dismember";
		hint clusterFX = "Name of FX to play when bomb cleaves into clusters";
		hint friendlyFire = "If set then the one who created bomb explosion will also be affected by it";
		hint enableTrailFX = "If set then trail fx will be played on projectile release";
		hint alignToNormal = "If set entity will align it's Z axis with collision normal";
		
	
	private const var FX_TRAIL 						: name;								
	private const var FX_CLUSTER 					: name;								
	
	protected var itemName							: name;								
	private var targetPos 							: Vector;							
	private var isProximity							: bool;								
	private var isInWater							: bool;								
	private var isInDeepWater  						: bool;								
	private var isStuck								: bool;								
	protected var isCluster							: bool;								
	private var justPlayingFXs						: array<name>;						
	protected var loopDuration						: float;							
	protected var snapCollisionGroupNames 			: array<name>;						
	protected var stopCollisions					: bool;								
	protected var previousTargets					: array<CGameplayEntity>;			
	protected var targetsSinceLastCheck				: array<CGameplayEntity>;			
	private var	wasInTutorialTrigger				: bool;								
	private var decalRemainingTimes					: array< SPetardShownDecals > ;		
	protected var impactNormal						: Vector;
	protected saved var hasImpactFireDamage			: bool;
	protected saved var hasImpactFrostDamage		: bool;
	protected saved var hasLoopFireDamage			: bool;
	protected saved var hasLoopFrostDamage			: bool;
	
		default isStuck = false;
		default isCluster = false;
		default isProximity = false;
		default isInWater = false;
		default isInDeepWater = false;
		default stopCollisions = false;
		default FX_TRAIL = 'fx_trail';
		default FX_CLUSTER = 'fx_cluster_cleave';
		default dodgeable = true;
		default enableTrailFX = true;
		
	
	
	
	event OnDestroyed()
	{
		ProcessPetardDestruction();
	}
	event OnProcessThrowEvent( animEventName : name )
	{
		var throwPos : Vector;
		var boneIndex : int;
		var orientationTarget	: EOrientationTarget;
		var slideTargetActor : CActor;
		
		
		var dist, x, y, maxThrowRange : float;
		var playerPos : Vector;
		
		if ( animEventName == 'ProjectileThrow' )
		{
			if ( GetOwner() == thePlayer )
			{
				if ( thePlayer.GetDisplayTarget() )
					throwPos = thePlayer.GetLookAtPosition();
				else
				{
					orientationTarget = thePlayer.GetOrientationTarget();
					
					if (!GetOwner().HasBuff(EET_Hypnotized) && (orientationTarget == OT_Camera || orientationTarget == OT_CameraOffset) )
						throwPos = theCamera.GetCameraDirection() * 8 + GetOwner().GetWorldPosition();
					else
						throwPos = GetOwner().GetWorldForward() * 8 + GetOwner().GetWorldPosition();		
				}
			}			
			else
			{
				slideTargetActor = (CActor)( GetOwner().slideTarget );
			
				
				if( GetOwner().slideTarget && !GetOwner().HasBuff(EET_Hypnotized) &&
					( !slideTargetActor || ( slideTargetActor && GetAttitudeBetween(GetOwner(), GetOwner().slideTarget) == AIA_Hostile ) ) )
				{
					boneIndex = GetOwner().slideTarget.GetBoneIndex( 'pelvis' );
					if ( boneIndex > -1 )
						throwPos = MatrixGetTranslation( GetOwner().slideTarget.GetBoneWorldMatrixByIndex( boneIndex ) );
					else
						throwPos = GetOwner().slideTarget.GetWorldPosition();
				}
				else
				{
					orientationTarget = thePlayer.GetOrientationTarget();
					
					if (!GetOwner().HasBuff(EET_Hypnotized) && (orientationTarget == OT_Camera || orientationTarget == OT_CameraOffset) )
						throwPos = theCamera.GetCameraDirection() * 8 + GetOwner().GetWorldPosition();
					else
						throwPos = GetOwner().GetWorldForward() * 8 + GetOwner().GetWorldPosition();		
				}
			}
			
			
			playerPos = thePlayer.GetWorldPosition();
			dist = VecDistance(throwPos,playerPos);
			maxThrowRange = theGame.params.MAX_THROW_RANGE;
			if(dist > maxThrowRange)
			{
				throwPos.X = playerPos.X + maxThrowRange/dist * (throwPos.X - playerPos.X);
				throwPos.Y = playerPos.Y + maxThrowRange/dist * (throwPos.Y - playerPos.Y);
			}
			
			
			ThrowProjectile( throwPos );
		}
		
		return super.OnProcessThrowEvent( animEventName );
	}
	
	public function GetAudioImpactName() : name
	{
		return audioImpactName;
	}
	
	protected function LoadDataFromItemXMLStats()
	{
		var atts, abs : array<name>;
		var j, i, iSize, jSize : int;
		var disabledAbility : SBlockedAbility;
		var dm : CDefinitionsManagerAccessor;
		var buff : SEffectInfo;
		var isLoopAbility : bool;
		var dmgRaw : SRawDamage;
		var type : EEffectType;
		var customAbilityName : name;
		var inv : CInventoryComponent;
		var abilityDisableDuration : float;
		var min, max : SAbilityAttributeValue;
		
		inv = GetOwner().GetInventory();
		
		if(!inv)
		{
			LogAssert(false, "W3Petard.LoadDataFromItemXMLStats: owner <<" + GetOwner() + ">> has no InventoryComponent!!!");
			return;
		}
		
		loopDuration = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, 'duration'));
		itemName = inv.GetItemName(itemId);
		
		inv.GetItemAbilities(itemId, abs);
		dm = theGame.GetDefinitionsManager();
		iSize = abs.Size();		
		for( i = 0; i < iSize; i += 1 )
		{
			isLoopAbility = dm.AbilityHasTag(abs[i], 'PetardLoopParams');
			if(!isLoopAbility)
				if(!dm.AbilityHasTag(abs[i], 'PetardImpactParams'))
					continue;
			
			dm.GetAbilityAttributeValue(abs[i], 'ability_disable_duration', min, max);
			abilityDisableDuration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			dm.GetContainedAbilities(abs[i], atts);
			jSize = atts.Size();
			for( j = 0; j < jSize; j += 1 )
			{
				
				if( IsEffectNameValid( atts[j] ) )
				{
					EffectNameToType(atts[j], type, customAbilityName);
					
					buff.effectType = type;
					buff.effectAbilityName = customAbilityName;					
					dm.GetAbilityAttributeValue(abs[i], atts[j], min, max);
					buff.applyChance = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
					
					if(isLoopAbility)
						loopParams.buffs.PushBack(buff);
					else
						impactParams.buffs.PushBack(buff);
				}
				else
				{
					disabledAbility.abilityName = atts[j];
					disabledAbility.timeWhenEnabledd = abilityDisableDuration;
					
					
					if(disabledAbility.timeWhenEnabledd == 0)
						disabledAbility.timeWhenEnabledd = -1;
					
					if(isLoopAbility)
						loopParams.disabledAbilities.PushBack(disabledAbility);
					else
						impactParams.disabledAbilities.PushBack(disabledAbility);
				}
			}
			
			dm.GetAbilityAttributes(abs[i], atts);
			jSize = atts.Size();
			for( j = 0; j < jSize; j += 1 )
			{
				
				if(IsDamageTypeNameValid(atts[j]))
				{				
					dmgRaw.dmgVal = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, atts[j]));
					if(dmgRaw.dmgVal == 0)
						continue;
					
					dmgRaw.dmgType = atts[j];
					
					if(isLoopAbility)
						loopParams.damages.PushBack(dmgRaw);
					else
						impactParams.damages.PushBack(dmgRaw);						
				}
			}
			
			
			if(isLoopAbility && loopParams.damages.Size() > 0)
			{
				loopParams.ignoresArmor = atts.Contains('ignoreArmor');
			}
			else if(!isLoopAbility && impactParams.damages.Size() > 0)
			{
				impactParams.ignoresArmor = atts.Contains('ignoreArmor');
			}
		}
	}
	
	
	
	
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
		
		
		AddTimer( 'ReleaseProjectile', 0.01, false, , , true );
		
		
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
	
	
	timer function ReleaseProjectile( time : float , id : int)
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
			ShootProjectileAtPosition( 20.0f, 15.0f, targetPos, theGame.params.MAX_THROW_RANGE, collisionGroups);
		}
		else
		{
			ShootProjectileAtPosition( 20.0f, 15.0f, targetPos, theGame.params.MAX_THROW_RANGE );
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
		var depthTestPos, petardPos, collisionPos, collisionNormal, yVec : Vector;
		var template : CEntityTemplate;
		var npc : CNewNPC;
		var victim : CActor;
		var entity : CEntity;
		var rot : EulerAngles;
		var rotMatrix, m1, m2, m3 : Matrix;
		var waterEntity : CEntity; 
		
		if(stopCollisions)
			return true;
		
		OnImpact();
		
		if(collidingComponent)
			entity = collidingComponent.GetEntity();
		
		
		if(entity == GetOwner())
			return true;
			
		if(collidingComponent)
		{
			victim = (CActor)entity;
			npc = (CNewNPC)(victim);
		}
			
		if ( !CanCollideWithVictim( victim ) )
			return true;
		
		impactNormal = normal;
		
		
		if ( npc && npc.HasAbility( 'RepulseProjectiles' ) )
		{
			bounceOfVelocityPreserve = 0.8;
			BounceOff( normal, pos );
			victim.PlayEffect( 'lightning', this );
			this.Init( npc );
			return true;
		}
		
		victim.SignalGameplayEvent( 'HitByBomb' );	
		
		
		if( itemName == 'Grapeshot 2' || itemName == 'Grapeshot 3' )
		{
			if( npc && npc.IsShielded( thePlayer ) )
			{
				npc.ProcessShieldDestruction();
			}
		}
		
		
		
		theGame.VibrateControllerVeryHard();	
			
		
		if ( hitCollisionsGroups.Contains( 'Water' ) )
		{
			if(isInWater)
				return true;
				
			isInWater = true;
		
			petardPos = GetWorldPosition();
			depthTestPos = petardPos;
			depthTestPos.Z -= 1;
			
			if ( !theGame.GetWorld().StaticTrace(petardPos, depthTestPos, collisionPos, collisionNormal, snapCollisionGroupNames) )
				isInDeepWater = true;
			
			
			
			
			if(isInWater && !waterFXPlayed)
			{
				template = (CEntityTemplate)LoadResource("water_splash_small");
				waterEntity = theGame.CreateEntity(template, petardPos, thePlayer.GetWorldRotation());				
				if(isInDeepWater)
					waterEntity.PlayEffect('splash_big');
				else
					waterEntity.PlayEffect('splash');
				waterFXPlayed = true;
				waterEntity.AddTag('bomb_water_splash');
				waterEntity.DestroyAfter(6.f);
				waterEntity.SoundEvent("fx_water_object_splash_small");
			}
			
			if(isInDeepWater)
			{
				stopCollisions = true;
				DestroyAfter(3);
			}
			
			return true;
		}
		
		
		StopFlying();		
			
		if(isProximity || FactsQuerySum('debug_petards_proximity') > 0)
		{
			PlayEffectSingle('sparks');
			
			GetComponent("ProximityActivationArea").SetEnabled(true);
			AddTimer( 'DetonationTimer', theGame.params.PROXIMITY_PETARD_IDLE_DETONATION_TIME, , , , true );
			isStuck = true;
		}
		else
		{
			ProcessEffect( pos, (CGameplayEntity)entity );
		}
		
		if( alignToNormal )
		{
			
			
			
			m1 = MatrixBuildFromDirectionVector( normal );
			m2 = MatrixBuiltRotation( EulerAngles( -90, 0, 0 ) );
			m3 = m1 * m2;
			rot = MatrixGetRotation( m3 );
			
			TeleportWithRotation( GetWorldPosition(), rot );
			
		}
	}
	
	private var waterFXPlayed : bool;
	
	
	
	protected function StopFlying()
	{		
		if( enableTrailFX )
		{
			StopEffect(FX_TRAIL);
		}
		stopCollisions = true;
		StopProjectile();
	}
		
	event OnRangeReached()
	{	
		StopFlying();
		ProcessEffect();
	}
	
	event OnInteractionActivated(interactionComponentName : string, activator : CEntity)
	{
		if((isProximity || FactsQuerySum('debug_petards_proximity') > 0) && interactionComponentName == "ProximityActivationArea" && IsRequiredAttitudeBetween(GetOwner(), activator, true))
			ProcessEffect();	
	}
	
	
	timer function DetonationTimer( detlaTime : float , id : int)
	{
		ProcessEffect();
	}
	
	
	
	
		
	
	public function ProcessEffect( optional explosionPosition : Vector, optional collidedTarget : CGameplayEntity )
	{
		var targets, additionalTargets : array< CGameplayEntity >;
		var i : int;
		var victimTags, attackerTags : array<name>;
		var dist, camShakeStr, camShakeStrFrac : float;
		var temp, isPerk16Active : bool;
		var phantom : CPhantomComponent;
		var meshes : array<CComponent>;
		var mesh : CMeshComponent;
		var npc : CNewNPC;
		
		
		if(isInDeepWater || (noLoopEffectIfHitWater && isInWater) )
		{
			Destroy();
			return;
		}
		
		
		stopCollisions = true;
		
		
		meshes = GetComponentsByClassName('CMeshComponent');
		for(i=0; i<meshes.Size(); i+=1)
		{
			mesh = (CMeshComponent)meshes[i];
			if( !mesh )
			{
				continue;
			}
			
			mesh.SetVisible(false);
			mesh.SetEnabled(false);
		}
		
		
		if(!isCluster && !ignoreBombSkills && (W3PlayerWitcher)GetOwner() && GetWitcherPlayer().CanUseSkill(S_Alchemy_s11) && !HasTag('Snowball'))
		{
			ProcessClusterBombs();
			return;
		}
		
		if ( explosionPosition == Vector( 0, 0, 0 ) )
		{
			explosionPosition = this.GetWorldPosition();
		}
		
		
		explosionPosition = explosionPosition + Vector( 0.0f, 0.0f, 0.1f );
		FindGameplayEntitiesInSphere(targets, explosionPosition, impactParams.range, 1000, '', FLAG_TestLineOfSight);	
		
		if( targets.Size() == 0 )
		{
			explosionPosition = explosionPosition - Vector( 0.0f, 0.0f, 0.2f ); 
			FindGameplayEntitiesInSphere(targets, explosionPosition, impactParams.range, 1000, '', FLAG_TestLineOfSight);	
		}
		
		
		if ( itemName == 'Silver Dust Bomb 1' || itemName == 'Silver Dust Bomb 2' || itemName == 'Silver Dust Bomb 3' )
		{
			FindGameplayEntitiesInSphere(additionalTargets, explosionPosition, impactParams.range * 1.5, 1000, 'vampire', FLAG_TestLineOfSight);	
		}
		
		if ( additionalTargets.Size() > 0 )
		{
			for ( i = 0 ; i < additionalTargets.Size() ; i += 1 )
			{
				if ( !targets.Contains( additionalTargets[i] ) )
				{
					targets.PushBack( additionalTargets[i] );
				}
			}
		}
		
		if(collidedTarget && !targets.Contains(collidedTarget))
			targets.PushBack(collidedTarget);
			
		if( caster == GetWitcherPlayer() && GetWitcherPlayer().CanUseSkill( S_Perk_16 ) )
		{
			isPerk16Active = true;
		}
		
		for( i=targets.Size() - 1; i >= 0; i -= 1)
		{		
			if( !targets[ i ].IsAlive() )
			{
				npc = (CNewNPC)targets[i];
				
				if(npc)
				{
					
					npc.SignalGameplayEvent('AbandonAgony');
					
					
					
					
					
					if( !npc.HasAbility( 'mon_bear_base' )
						&& !npc.HasAbility( 'mon_golem_base' )
						&& !npc.HasAbility( 'mon_endriaga_base' )
						&& !npc.HasAbility( 'mon_gryphon_base' )
						&& !npc.HasAbility( 'q604_shades' )
						&& !npc.IsAnimal()	)
					{
						npc.SetKinematic(false);
					}
				}
				else
				{
					
					if( !targets[i].HasTag( 'TargetableByBomb' ) )
					{
						targets.EraseFast(i);
					}
				}
				
			}
			
			if ( targets[i] == GetWitcherPlayer() && isPerk16Active )
			{
				targets.EraseFast( i );
			}	
			else if ( targets[ i ] == this )
			{
				targets.EraseFast(i);
			}
			
			else if( targets[i] == thePlayer && GetOwner() == thePlayer && (W3WhiteFrost)this )
			{
				targets.EraseFast(i);
			}
		}
		
		
		SnapComponents(true);
				
		
		ProcessMechanicalEffect(targets, true);
		
		
		if(cameraShakeStrMin + cameraShakeStrMax > 0)	
		{
			dist = VecDistance(GetOwner().GetWorldPosition(), GetWorldPosition());
			
			if(dist <= cameraShakeRange)
			{
				camShakeStrFrac = (cameraShakeRange - dist) / cameraShakeRange;
				camShakeStr = cameraShakeStrMin + camShakeStrFrac * (cameraShakeStrMax - cameraShakeStrMin);
				
				
				GCameraShake(camShakeStr, true, GetWorldPosition(), impactParams.range * 2);
			}
		}
		
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'BombExplosionAction', 10.0, 50.0f, -1, -1, true); 
		
		
		ProcessEffectPlayFXs(true);

		if(loopDuration > 0)
		{
			ProcessLoopEffect();
		}
		else
		{
			OnTimeEndedFunction(0);
		}
	}

	protected function SnapComponents(isImpact : bool)
	{
		var params : SPetardParams;
		var i : int;
		var pos : Vector;
		
		if(isImpact)
			params = impactParams;
		else
			params = loopParams;
			
		for(i=0; i<params.componentsToSnap.Size(); i+=1)
			SnapComponentByName(params.componentsToSnap[i], 2, 0.25, snapCollisionGroupNames, pos);
	}
	
	protected function ProcessLoopEffect()
	{
		
		LoopComponentsEnable(true);
		
		
		SnapComponents(false);
		
		
		ProcessEffectPlayFXs(false);
		
		
		AddTimer('OnTimeEnded', loopDuration, false, , , true);
		AddTimer('Loop', 0.1f, true, , , true);	
	}
	
	protected function LoopComponentsEnable(enable : bool)
	{
		var i : int;
		var component : CComponent;
		
		for(i=0; i<componentsEnabledOnLoop.Size(); i+=1)
		{
			component = GetComponent(componentsEnabledOnLoop[i]);
			if(component)
				component.SetEnabled(enable);
		}
	}
	
	timer function Loop(dt : float, id : int)
	{
		LoopFunction(dt);
	}
	
	protected function ProcessPetardDestruction ()
	{
		var i : int;
		
		for(i=0; i<previousTargets.Size(); i+=1)
			ProcessTargetOutOfArea(previousTargets[i]);		
	}
	
	protected function LoopFunction(dt : float)
	{
		var i : int;
		var targets : array<CGameplayEntity>;
		var pos : Vector;
	
		pos = GetWorldPosition();
		pos.Z += loopParams.cylinderOffsetZ;
		targetsSinceLastCheck.Clear();
		FindGameplayEntitiesInCylinder(targets, pos, loopParams.range, loopParams.cylinderHeight, 100000);
		
		
		targets.Remove(this);
		
		
		if( GetOwner() == thePlayer && GetWitcherPlayer().CanUseSkill( S_Perk_16 ) )
		{
			targets.Remove( thePlayer );
		}

		
		targetsSinceLastCheck.Resize(targets.Size());
		for(i=0; i<targetsSinceLastCheck.Size(); i+=1)
		{
			targetsSinceLastCheck[i] = targets[i];
		}
		
		
		ProcessMechanicalEffect( targetsSinceLastCheck, false, dt );
		
		
		for(i=0; i<previousTargets.Size(); i+=1)
		{
			if(!targetsSinceLastCheck.Contains( previousTargets[i] ))
			{
				ProcessTargetOutOfArea( previousTargets[i] );
			}
		}
		
		previousTargets.Clear();
		previousTargets = targetsSinceLastCheck;
		
		
		
	}
	
	
	protected function ProcessTargetOutOfArea(entity : CGameplayEntity)
	{
		var dm : CDefinitionsManagerAccessor;
		var j, k : int;
		var skill : ESkill;
		var successfullUnblock : bool;
		var actor : CActor;

		actor = (CActor)entity;
		if(!actor || !actor.IsAlive())
			return;
			
		
		dm = theGame.GetDefinitionsManager();
		successfullUnblock = false;
		for(j=0; j<loopParams.disabledAbilities.Size(); j+=1)
		{			
			if(loopParams.disabledAbilities[j].timeWhenEnabledd == -1 && dm.IsAbilityDefined(loopParams.disabledAbilities[j].abilityName))
			{
				
				skill = S_SUndefined;
				if(actor == thePlayer)
					skill = SkillNameToEnum(loopParams.disabledAbilities[j].abilityName);						 
				
				
				if(skill != S_SUndefined)
					successfullUnblock = thePlayer.BlockSkill(skill, false) || successfullUnblock;
				else
					successfullUnblock = actor.BlockAbility(loopParams.disabledAbilities[j].abilityName, false) || successfullUnblock;
			}
		}
		
		if(successfullUnblock)
		{
			
			for(k=0; k<loopParams.fxPlayedWhenAbilityDisabled.Size(); k+=1)						
				actor.StopEffect(loopParams.fxPlayedWhenAbilityDisabled[k]);
				
			for(k=0; k<loopParams.fxStoppedWhenAbilityDisabled.Size(); k+=1)						
				actor.PlayEffectSingle(loopParams.fxStoppedWhenAbilityDisabled[k]);
		}
	}
		
	timer function OnTimeEnded(dt : float, id : int)
	{
		OnTimeEndedFunction(dt);		
	}
	
	protected function OnTimeEndedFunction(dt : float)
	{
		LoopComponentsEnable(false);
		StopAllEffects();
		AddTimer('DestroyWhenNoFXPlayed', 1, true, , , true);
		RemoveTimer('Loop');
	}
	
	
	protected function ProcessEffectPlayFXs(isImpact : bool)
	{
		var params : SPetardParams;
		var i : int;
		var fx : array<name>;
		var decalRandomID : int;
	
		if(isImpact)
			params = impactParams;
		else
			params = loopParams;
			
		
		if(isInWater)
		{
			if(isCluster && params.fxClusterWater.Size() > 0)
			{
				fx = params.fxClusterWater;
			}
			else
			{
				fx = params.fxWater;
			}
		}
		else
		{
			if(isCluster && params.fxCluster.Size() > 0)
			{
				fx = params.fxCluster;
			}
			else
			{
				fx = params.fx;
			}
		}
		
		
		for(i=0; i<fx.Size(); i+=1)
			PlayEffectInternal(fx[i]);
			
		
		if( params.decalComponentNames.Size() > 0 )
		{
			decalRemainingTimes.Resize( params.decalComponentNames.Size() );
			
			if( params.decalComponentUseRandom )		
			{
				decalRandomID = RandRange( 0 , params.decalComponentNames.Size() );
				ShowDecalComponent( decalRandomID, params );
			}
			else										
			{
				for( i=0; i<params.decalComponentNames.Size(); i+= 1)
				{
					ShowDecalComponent( i, params );
				}
			}
		}
	}
	
	private function ShowDecalComponent ( decalID : int, params : SPetardParams )
	{
		var decalComp : CDecalComponent;
		var decalScale : Vector;
		var scaleModifier : float;
		
		decalComp = ( CDecalComponent ) GetComponent( params.decalComponentNames[ decalID ] );
					
		if( decalComp )
		{
			if( params.decalComponentScaleModifier )
			{
				scaleModifier = params.decalComponentScaleModifier;
				scaleModifier = RandRangeF( scaleModifier, -scaleModifier);
				
				decalScale = decalComp.GetLocalScale();
				decalScale = decalScale * ( 1 + scaleModifier );
				
				decalComp.SetScale( decalScale );
			}

			decalComp.SetVisible( true ) ;
			decalRemainingTimes[ decalID ].remainingShowTime = params.decalComponentVisibleTimes[ decalID ];
			decalRemainingTimes[ decalID ].componentName = params.decalComponentNames[ decalID ];
		}
	}
	
	 event OnImpact()
	{
		var j : int;
		
		
		for(j=0; j<impactParams.damages.Size(); j+=1)
		{
			if(impactParams.damages[j].dmgVal > 0)
			{
				if(impactParams.damages[j].dmgType == theGame.params.DAMAGE_NAME_FIRE)
				{
					hasImpactFireDamage = true;
				}
				else if(impactParams.damages[j].dmgType == theGame.params.DAMAGE_NAME_FROST)						
				{
					hasImpactFrostDamage = true;
				}
			}
		}
		for(j=0; j<loopParams.damages.Size(); j+=1)
		{
			if(loopParams.damages[j].dmgVal > 0)
			{
				if(loopParams.damages[j].dmgType == theGame.params.DAMAGE_NAME_FIRE)
				{
					hasLoopFireDamage = true;
				}
				else if(loopParams.damages[j].dmgType == theGame.params.DAMAGE_NAME_FROST)						
				{
					hasLoopFrostDamage = true;
				}
			}
		}
	}

	
	protected function ProcessMechanicalEffect(targets : array<CGameplayEntity>, isImpact : bool, optional dt : float)
	{			
		var i, index, j, k : int;
		var action : W3DamageAction;
		var none : SAbilityAttributeValue;
		var atts : array<name>;
		var newDamage : SRawDamage;
		var params : SPetardParams;
		var attackerTags, allVictimsTags, targetTags : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var actorTarget : CActor;
		var surface	: CGameplayFXSurfacePost;		
		var successfullBlock, canUsePerk20 : bool;
		var hitType : EHitReactionType;
		var npc : CNewNPC;
		var DoTBuff : W3BuffDoTParams;
		
		
		for(i=targets.Size()-1; i>=0; i-=1)
		{
			
			if( (CActionPoint)targets[i] || (W3Petard)targets[i] )
			{
				targets.Erase(i);
				continue;
			}
			
			if(GetAttitudeBetween(GetOwner(), targets[i]) == AIA_Friendly)
			{
				actorTarget = (CActor)targets[i];
				
				
				if(!actorTarget || (targets[i] == GetOwner() && GetOwner() == thePlayer))
					continue;
				
				
				targets.Erase(i);
			}
		}
		
		
		
		
		if(isImpact)
			params = impactParams;
		else
			params = loopParams;
			
		
		if(params.surfaceFX.fxType >= 0 && !isInWater)
		{
			surface = theGame.GetSurfacePostFX();
			surface.AddSurfacePostFXGroup(GetWorldPosition(), params.surfaceFX.fxFadeInTime, params.surfaceFX.fxLastingTime, params.surfaceFX.fxFadeOutTime, params.surfaceFX.fxRadius, params.surfaceFX.fxType);
		}	
		
		if(targets.Size() == 0)
			return;				
			
		if(isImpact)
		{
			
			
		
			
			if( !ignoreBombSkills && (W3PlayerWitcher)GetOwner() && GetWitcherPlayer().CanUseSkill(S_Alchemy_s10) && !HasTag('Snowball'))
			{
				theGame.GetDefinitionsManager().GetAbilityAttributes(SkillEnumToName(S_Alchemy_s10), atts);
				
				for(j=0; j<atts.Size(); j+=1)
				{
					if(IsDamageTypeNameValid(atts[j]))
					{
						index = -1;
						for(i=0; i<params.damages.Size(); i+=1)
						{
							if(params.damages[i].dmgType == atts[j])
							{
								index = i;
								break;
							}
						}
						
						
						if(index != -1)
						{
							params.damages[index].dmgVal += CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Alchemy_s10, atts[j], false, true)) * thePlayer.GetSkillLevel(S_Alchemy_s10);
						}
						else
						{
							newDamage.dmgType = atts[j];
							newDamage.dmgVal = CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Alchemy_s10, atts[j], false, true)) * thePlayer.GetSkillLevel(S_Alchemy_s10);
							params.damages.PushBack(newDamage);
						}
					}
				}
			}
		}
		
		dm = theGame.GetDefinitionsManager();
					
		
		if(isImpact)
			hitType = hitReactionType;
		else
			hitType = EHRT_None;
		
		
		DoTBuff = new W3BuffDoTParams in this;
		DoTBuff.isFromBomb = true;
		
		if( (W3PlayerWitcher)GetOwner() && GetWitcherPlayer().CanUseSkill( S_Perk_20 ) )
		{
			DoTBuff.isPerk20Active = true;
			canUsePerk20 = true;				
		}
		
		
		
		
		for(i=0; i<targets.Size(); i+=1)
		{	
			
			targetTags = targets[i].GetTags();
			ArrayOfNamesAppendUnique(allVictimsTags, targetTags);
			
			
			actorTarget = (CActor)targets[i];
			if(!actorTarget)
			{
				if( isImpact )
				{
					if( hasImpactFireDamage )
					{
						targets[i].OnFireHit(this);
					}
					if( hasImpactFrostDamage )
					{
						targets[i].OnFireHit(this);
					}
				}
				else
				{
					if( hasLoopFireDamage )
					{
						targets[i].OnFireHit(this);
					}
					if( hasLoopFrostDamage )
					{
						targets[i].OnFireHit(this);
					}
				}
				
				
				if(isFromAimThrow && wasInTutorialTrigger && ShouldProcessTutorial('TutorialThrowHold'))
				{
					for(j=0; j<targetTags.Size(); j+=1)
					{
						FactsAdd("aimthrowed_" + targetTags[j]);
					}
				}
					
				continue;
			}
			
			
			if( actorTarget && !actorTarget.IsAlive() )
			{
				continue;
			}
			
			
			action = new W3DamageAction in theGame.damageMgr;
			action.Initialize(GetOwner(), actorTarget, this, 'petard', hitType, CPS_Undefined, false, true, false, false);
			action.SetHitAnimationPlayType(params.playHitAnimMode);
			action.SetIgnoreArmor(params.ignoresArmor);
			action.SetProcessBuffsIfNoDamage(true);
			action.SetIsDoTDamage(dt);
			
			for(j=0; j<params.damages.Size(); j+=1)
			{
				if(dt > 0)
					action.AddDamage(params.damages[j].dmgType, params.damages[j].dmgVal * dt);
				else
					action.AddDamage(params.damages[j].dmgType, params.damages[j].dmgVal);
			}

			for(j=0; j<params.buffs.Size(); j+=1)
			{
				
				
				
				params.buffs[j].effectCustomParam = DoTBuff;
				
				
				action.AddEffectInfo(params.buffs[j].effectType, params.buffs[j].effectDuration, params.buffs[j].effectCustomValue, params.buffs[j].effectAbilityName, params.buffs[j].effectCustomParam, params.buffs[j].applyChance);
			}
			
			theGame.damageMgr.ProcessAction(action);
			
			delete action;
						
			
			successfullBlock = false;
			for(j=0; j<params.disabledAbilities.Size(); j+=1)
				if(dm.IsAbilityDefined(params.disabledAbilities[j].abilityName))
					successfullBlock = BlockTargetsAbility(actorTarget, params.disabledAbilities[j].abilityName, params.disabledAbilities[j].timeWhenEnabledd) || successfullBlock;					
			
			
			for(k=0; k<params.fxPlayedOnHit.Size(); k+=1)
				actorTarget.PlayEffectSingle(params.fxPlayedOnHit[k]);
			
			
			if(successfullBlock)
			{
				
				for(k=0; k<params.fxPlayedWhenAbilityDisabled.Size(); k+=1)						
					actorTarget.PlayEffectSingle(params.fxPlayedWhenAbilityDisabled[k]);
					
				for(k=0; k<params.fxStoppedWhenAbilityDisabled.Size(); k+=1)						
					actorTarget.StopEffect(params.fxStoppedWhenAbilityDisabled[k]);
			}
				
			
			npc = (CNewNPC)actorTarget;
			if(npc && npc.GetNPCType() == ENGT_Guard && !npc.IsInCombat() )
			{
				npc.SignalGameplayEventParamObject('BeingHitAction', GetOwner());
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( npc, 'BeingHitAction', 8.0, 1.0f, 999.0f, 1, false); 
			}
		}

		
		if(allVictimsTags.Size() > 0)
		{
			attackerTags = GetOwner().GetTags();
			
			AddHitFacts( allVictimsTags, attackerTags, "_weapon_hit" );
			AddHitFacts( allVictimsTags, attackerTags, "_bomb_hit" );
			AddHitFacts( allVictimsTags, attackerTags, "_bomb_hit_type_" + PrintFactFriendlyPetardName() );
		}		
	}
	
	
	protected function BlockTargetsAbility(target : CActor, abilityName : name, blockDuration : float, optional unlock : bool) : bool
	{
		var skill : ESkill;
	
		
		skill = S_SUndefined;
		if(target == thePlayer)					
			skill = SkillNameToEnum(abilityName);						 
		
		
		if(skill != S_SUndefined)
			return thePlayer.BlockSkill(skill, !unlock, blockDuration);
		else
			return target.BlockAbility(abilityName, true, blockDuration);
	}
	
	timer function DelayedRestoreCollisions(dt : float, id : int)
	{
		stopCollisions = false;
	}
	
	
	private function ProcessClusterBombs()
	{
		var target : CActor = thePlayer.GetTarget();
		var i, clusterNbr : int;
		var cluster : W3Petard;
		var targetPosCluster, clusterInitPos : Vector;
		var angle, velocity, distLen : float;
		var clusterTemplate : CEntityTemplate;
		var dmgRaw : SRawDamage;
		var cachedDamages : array<SRawDamage>;
		var atts : array<name>;
		var distanceToTarget : float;
		var projectileFlightTime : float;
		var collisionGroups : array<name>;
	
		clusterInitPos = GetWorldPosition();
		clusterInitPos.Z += radius + 0.15;
		
		clusterNbr = thePlayer.GetSkillLevel(S_Alchemy_s11) + 1;
		
		for(i=0; i<clusterNbr; i+=1)
		{			
			cluster = (W3Petard)Duplicate();
			cluster.Init(GetOwner());
			cluster.isCluster = true;
			cluster.isProximity = false;					
			cluster.AddTimer('DelayedRestoreCollisions', 0.2);	
			
			
			targetPosCluster.X = SgnF(RandF()-0.5) * (1+RandF()*3);
			targetPosCluster.Y = SgnF(RandF()-0.5) * (1+RandF()*3);
			targetPosCluster.Z = 0;
			
			distLen = VecLength2D(targetPosCluster);	
			
			targetPosCluster += GetWorldPosition();		
			
			angle = (9 - distLen) * 10;					
			velocity = 4 + distLen/2;					
			
			
			if( target.HasTag('AddRagdollCollision'))
			{
				collisionGroups.PushBack('Ragdoll');
				collisionGroups.PushBack('Terrain');
				collisionGroups.PushBack('Static');
				collisionGroups.PushBack('Water');
				collisionGroups.PushBack('Destructible');
				cluster.ShootProjectileAtPosition( angle, velocity, targetPosCluster, theGame.params.MAX_THROW_RANGE, collisionGroups );
			}
			else
			{
				cluster.ShootProjectileAtPosition( angle, velocity, targetPosCluster, theGame.params.MAX_THROW_RANGE );
			}
			cluster.PlayEffectSingle(FX_TRAIL);
			
			if ( dodgeable )
			{
				distanceToTarget = VecDistance( thePlayer.GetWorldPosition(), target.GetWorldPosition() );		
				
				
				projectileFlightTime = distanceToTarget / velocity;
				target.SignalGameplayEventParamFloat('Time2DodgeBomb', projectileFlightTime );
			}
		}
		
		
		PlayEffect(FX_CLUSTER);		
		justPlayingFXs.PushBack(FX_CLUSTER);
		
		AddTimer('DestroyWhenNoFXPlayed', 1, true, , , true);
		stopCollisions = true;
	}
	
	timer function DestroyWhenNoFXPlayed(dt : float, id : int)
	{
		DestroyWhenNoFXPlayedFunction(dt);
	}
	
	
	protected function DestroyWhenNoFXPlayedFunction(dt : float) : bool
	{
		var i : int;
		var decalComp : CDecalComponent;
		var stillHasDecalToShow : bool;
	
		for(i=0; i<justPlayingFXs.Size(); i+=1)
		{
			if(IsEffectActive(justPlayingFXs[i]))
			{
				return false;
			}
		}
		
		
		stillHasDecalToShow = false;
		for( i = 0; i < decalRemainingTimes.Size(); i += 1 )
		{
			if( decalRemainingTimes[ i ].remainingShowTime > 0.f )
			{
				decalRemainingTimes[ i ].remainingShowTime -= dt;
				
				if( decalRemainingTimes[ i ].remainingShowTime > 0.f )
				{
					stillHasDecalToShow = true;
				}
				else
				{
					decalComp = ( CDecalComponent ) GetComponent( decalRemainingTimes[ i ].componentName );
					if( decalComp )
					{
						decalComp.SetVisible( false ) ;
					}
				}
			}
		}
		
		if( stillHasDecalToShow )
		{
			return false;
		}
		
		RemoveTimer('DestroyWhenNoFXPlayed');
		DestroyAfter( 0.1f ); 
		return true;
	}
	
	protected function PlayEffectInternal(fx : name)
	{
		
		PlayEffectSingle(fx);
		
		
		justPlayingFXs.PushBack(fx);
	}
	
	public function DismembersOnKill() : bool
	{
		return dismemberOnKill;
	}
	
	public function GetImpactRange() : float			{return impactParams.range;}
	public function GetAoERange() : float				{return loopParams.range;}
	public function IsStuck() : bool					{return isStuck;}
	public function DisableProximity()					{isProximity = false;}
	public function IsProximity() : bool				{return isProximity;}
	
	
	
	private function PrintFactFriendlyPetardName() : string
	{
		return StrLower(StrReplaceAll( NameToString(itemName) , " ", "_" ));
	}
	
	
}
