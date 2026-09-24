/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EOilBarrelOperation
{
	OBO_Ignite,
	OBO_Explode,
}

class COilBarrelEntity extends CGameplayEntity
{
	editable var fx_onInteraction	: name;
	editable var damageRadius		: float;
	editable var damageVal			: float;
	editable var explodeAfter		: float;
	editable var destroyEntAfter	: float;
	editable var randomizeTime		: bool;
	editable var onFireDamagePerSec	: float;
	
	private var isSetOnFire : bool;
	private var isExploding : bool;
	private var onFireDamageArea : CTriggerAreaComponent;
	private var entitiesInOnFireArea : array<CGameplayEntity>;
	
	default randomizeTime = true;
	default isSetOnFire = false;
	default isExploding = false;
	default fx_onInteraction = 'fire';
	default damageRadius = 5;
	default damageVal = 50;
	default explodeAfter = 3.0;
	default destroyEntAfter = 10.0;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{	
		isExploding = false;
		super.OnSpawned(spawnData);
	}
	
	event OnFireHit(source : CGameplayEntity)
	{
		var destructionCmp : CDestructionSystemComponent;

		super.OnFireHit(source);
	
		destructionCmp = (CDestructionSystemComponent) GetComponentByClassName('CDestructionSystemComponent');
		if( destructionCmp && destructionCmp.IsDestroyed() )
		{
		}
		else
		{
			if((COilBarrelEntity)source || (W3Petard)source || (W3ExplosiveBolt)source)
				Explosion(0);
			else
				SetOnFire( explodeAfter, randomizeTime );
		}
	}
	
	private function EnableOnFireDamageArea()
	{
		var i : int;
		var ents : array<CGameplayEntity>;
		
		onFireDamageArea.SetEnabled(true);
		FindGameplayEntitiesInRange(ents, this, 10, 100000);
		for(i=0; i<ents.Size(); i+=1)
			if(!((COilBarrelEntity)ents[i]) && onFireDamageArea.TestEntityOverlap(ents[i]))
				entitiesInOnFireArea.PushBack(ents[i]);
				
		AddTimer('OnFireTimer', 0.0001, true, , , true);
	}				
	
	function SetOnFire( explTime : float, randomize : bool )
	{
		if( !isSetOnFire )
		{
			onFireDamageArea = (CTriggerAreaComponent)GetComponent('OnFireDamageArea');
			if(onFireDamageArea)
				EnableOnFireDamageArea();
			
			PlayEffect( fx_onInteraction );
			if( randomize )
				AddTimer( 'Explosion', explTime + RandRangeF( 1, 0 ), , , , true );
			else
				AddTimer( 'Explosion', explTime, , , , true );
				
			RemoveTag( theGame.params.TAG_SOFT_LOCK );	
			isSetOnFire = true;	
		}
	}
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var ent : CGameplayEntity;
		
		if(area == onFireDamageArea)
		{
			ent = (CGameplayEntity)activator.GetEntity();
			if(ent && !entitiesInOnFireArea.Contains(ent))
				entitiesInOnFireArea.PushBack(ent);
				
			if(entitiesInOnFireArea.Size() == 1)
				AddTimer('OnFireTimer', 0.0001, true, , , true);
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var ent : CGameplayEntity;
		
		if(area == onFireDamageArea)
		{
			ent = (CGameplayEntity)activator.GetEntity();
			if(ent)
				entitiesInOnFireArea.Remove(ent);
		}
	}
	
	timer function OnFireTimer(dt : float, id : int)
	{
		var i : int;
		var actor : CActor;
		var damageAction : W3DamageAction;
	
		
		if(isExploding)
		{
			RemoveTimer('OnFireTimer');
			return;
		}
		
		if(entitiesInOnFireArea.Size() == 0)
			RemoveTimer('OnFireTimer');
			
		for(i=entitiesInOnFireArea.Size()-1; i>=0; i-=1)
		{
			actor = (CActor)entitiesInOnFireArea[i];
			
			if(actor && onFireDamagePerSec > 0)
			{
				if(!actor.IsAlive())
				{
					entitiesInOnFireArea.Erase(i);
					continue;					
				}
				
				damageAction = new W3DamageAction in this;
				damageAction.Initialize(this, actor, this, this, EHRT_None, CPS_Undefined, false, false, false, true);
				damageAction.AddDamage(theGame.params.DAMAGE_NAME_FIRE, onFireDamagePerSec * dt);
				damageAction.SetIsDoTDamage(dt);
				damageAction.SetCanPlayHitParticle(false);
				theGame.damageMgr.ProcessAction(damageAction);
				delete damageAction;
			}
			else if(entitiesInOnFireArea[i] != this)
			{
				entitiesInOnFireArea[i].OnFireHit(this);
			}
		}
	}

	timer function Explosion( deltaTime : float, optional id : int)
	{
		var damage : W3DamageAction;
		var entitiesInRange : array< CGameplayEntity >;
		var i : int;
		var targetEntity : CActor;
		
		if(isExploding)
			return;
			
		isExploding = true;
		
		if(onFireDamageArea)
			onFireDamageArea.SetEnabled(false);
			
		StopAllEffects();
		PlayEffect( 'explosion' );
		PlayEffect( 'fire_ground' );
		GCameraShake( 1.5, true, GetWorldPosition(), 20.0f );
		AddTimer( 'DestroyEnt', destroyEntAfter + RandRangeF( 1.5 ) );
		
		
		if ( thePlayer.IsCameraLockedToTarget() && thePlayer.GetDisplayTarget() == this )
		{
			thePlayer.OnForceSelectLockTarget();
		}
		
		entitiesInRange = GatherTargets();		
		entitiesInRange.Remove(this);
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			targetEntity = (CActor)entitiesInRange[i];
			if(targetEntity)
			{
				damage = new W3DamageAction in this;
				
				damage.Initialize( this, entitiesInRange[i], NULL, this, EHRT_None, CPS_Undefined, false, false, false, true );
				if ( targetEntity == GetWitcherPlayer() )
					damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, damageVal * (int)GetWitcherPlayer().GetLevel() );
				else
					damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, damageVal * (int)CalculateAttributeValue(targetEntity.GetAttributeValue('level',,true)) );
				damage.AddEffectInfo(EET_Burning);
				damage.AddEffectInfo(EET_KnockdownTypeApplicator);
				damage.SetProcessBuffsIfNoDamage(true);
				theGame.damageMgr.ProcessAction( damage );
				
				delete damage;
			}
			else
			{
				entitiesInRange[i].OnFireHit(this);
			}
		}
		
		
		if(onFireDamageArea)
			onFireDamageArea.SetEnabled(false);
	}
	
	
	
	
	
	
	
	private function GatherTargets() : array<CGameplayEntity>
	{
		var ents : array<CGameplayEntity>;
		var barrelPosMiddle, targetPosMiddle, collisionPos, collisionNormal : Vector;
		var i : int;
		var box : Box;
		var height : float;
		var world : CWorld;
				
		world = theGame.GetWorld();
		GetStorageBounds(box);
		height = AbsF(box.Min.Z - box.Max.Z);
		barrelPosMiddle = GetWorldPosition() + GetWorldUp() * (height/2);
			
		
		FindGameplayEntitiesInSphere(ents, barrelPosMiddle, damageRadius, 1000);
		
		
		for(i=ents.Size()-1; i>=0; i-=1)
		{
			
			if( (W3BoltProjectile)ents[i] || (W3SignEntity)ents[i] || (CollisionTrajectory)ents[i])
			{
				ents.Erase(i);
				continue;
			}
		
			ents[i].GetStorageBounds(box);
			height = AbsF(box.Min.Z - box.Max.Z);
			targetPosMiddle = ents[i].GetWorldPosition() + ents[i].GetWorldUp() * (height/2);
			
			
			if(world.StaticTrace(barrelPosMiddle, targetPosMiddle, collisionPos, collisionNormal))
			{
				
				ents.Erase(i);				
			}			
		}
		
		return ents;
	}
	
	timer function DestroyEnt( deltaTime : float , id : int)
	{
		StopAllEffects();
		Destroy();
	}
	
	event OnManageOilBarrel( operations : array< EOilBarrelOperation > )
	{
		if(operations.Contains(OBO_Explode))
			Explosion(0);
		else if(operations.Contains(OBO_Ignite))
			SetOnFire(explodeAfter,randomizeTime);
	}
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return !isExploding;
	}	
}