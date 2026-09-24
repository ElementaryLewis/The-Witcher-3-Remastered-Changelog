/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3WhiteFrost extends W3Petard
{
	editable var waveProjectileTemplate : CEntityTemplate;
	editable var freezeNPCFadeInTime : float;
	editable var waveSpeedModifier : float;
	editable var HAX_waveRadius : float;

	private var collisionMask : array<name>;
	private var shaderSpeed : float;							
	private var totalTime : float;								
	private var collidedEntities : array<CGameplayEntity>;		
	private var waveProjectile : W3WhiteFrostWaveProjectile;	
	
		hint waveSpeedModifier = "Multiplier for wave progression speed - freezing effect on actors";
		hint HAX_waveRadius = "HACK - surface fx radius is not properly calculated - fixed max radius";

	protected function ProcessLoopEffect()
	{
		
		SnapComponents(false);
		
		
		LoopComponentsEnable(true);		
		
		
		ProcessEffectPlayFXs(false);
		
		
		totalTime = 0;
		
		
		shaderSpeed = HAX_waveRadius / impactParams.surfaceFX.fxFadeInTime * waveSpeedModifier;
		
		AddTimer('OnTimeEnded', loopDuration, false, , , true);
		AddTimer('WaveProjectile', 0.3, true, , , true);
		
		
		WaveProjectile(0.3);
	}
	
	protected function LoadDataFromItemXMLStats()
	{
		var customParam : W3FrozenEffectCustomParams;
		var i : int;
		
		super.LoadDataFromItemXMLStats();
		
		
		customParam = new W3FrozenEffectCustomParams in this;
		customParam.freezeFadeInTime = freezeNPCFadeInTime;
		for(i=0; i<impactParams.buffs.Size(); i+=1)
		{
			if(impactParams.buffs[i].effectType == EET_Frozen)
			{
				impactParams.buffs[i].effectCustomParam = customParam;
				break;
			}
		}
	}
	
	
	timer function WaveProjectile(dt : float, optional id : int)
	{
		totalTime += dt;
		
		
		if(!waveProjectile)
		{
			waveProjectile = (W3WhiteFrostWaveProjectile)theGame.CreateEntity(waveProjectileTemplate, GetWorldPosition());			
			waveProjectile.Init(this);
			waveProjectile.SetWhiteFrost(this);
			
			collisionMask.PushBack('Character');
			collisionMask.PushBack('Static');
			collisionMask.PushBack('RigidBody');
			collisionMask.PushBack('Corpse');
		}
		
		waveProjectile.SphereOverlapTest( totalTime * shaderSpeed, collisionMask );
		
		
		thePlayer.GetVisualDebug().AddSphere(EffectTypeToName(RandRange((int)EET_EffectTypesSize)), totalTime * shaderSpeed, GetWorldPosition(), true, Color(0,0,255), 0.15);
		
		
		if(totalTime >= impactParams.surfaceFX.fxFadeInTime)
		{
			RemoveTimer('WaveProjectile');			
			waveProjectile.Destroy();
		}		
	}
	
	protected function ProcessMechanicalEffect(targets : array<CGameplayEntity>, isImpact : bool, optional dt : float)
	{
		var spikeEnt : CEntity;
		var entityTemplate : CEntityTemplate;
		var rot : EulerAngles;
		var pos, basePos : Vector;
		var i : int;
		var angle, radius : float;
		
		super.ProcessMechanicalEffect( targets, isImpact, dt );
		
		if( isImpact && impactNormal.Z >= 0.8f )
		{
			
			entityTemplate = (CEntityTemplate) LoadResource( 'ice_spikes_large' );	
			if ( entityTemplate )
			{
				pos = GetWorldPosition();
				pos = TraceFloor( pos );
				rot.Pitch = 0.f;
				rot.Roll = 0.f;
				rot.Yaw = 0.f;
				
				spikeEnt = theGame.CreateEntity( entityTemplate, pos, rot );
				spikeEnt.DestroyAfter( 40.f );
			}
			
			
			entityTemplate = (CEntityTemplate) LoadResource( 'ice_spikes' );
			basePos = GetWorldPosition();
			for( i=0; i<3; i+=1 )
			{
				
				radius = RandF() + 3.0;
				
				
				angle = i * 2 *( Pi() / 3 ) + RandRangeF( Pi()/18, -Pi()/18 );
				
				pos = basePos + Vector( radius * CosF( angle ), radius * SinF( angle ), 0 );
				pos = TraceFloor( pos );
				
				rot.Pitch = 0.f;
				rot.Roll = 0.f;
				rot.Yaw = 0.f;
				
				spikeEnt = theGame.CreateEntity( entityTemplate, pos, rot );
				spikeEnt.DestroyAfter( 40.f );
			}			
		}
	}
	
	
	public function Collided(ent : CGameplayEntity)
	{
		var ents : array<CGameplayEntity>;
		var owner : CEntity;
	
		if(collidedEntities.Contains(ent))
			return;
			
		owner = EntityHandleGet(ownerHandle);
		if(owner && IsRequiredAttitudeBetween(ent, owner, false, false, true))
			return;
			
		collidedEntities.PushBack(ent);
		ents.PushBack(ent);
		ProcessMechanicalEffect(ents, true);
		ent.OnFrostHit(this);
	}
}


class W3WhiteFrostWaveProjectile extends CProjectileTrajectory
{
	private var frostEntity : W3WhiteFrost;
	
	public function SetWhiteFrost(f : W3WhiteFrost)
	{
		frostEntity = f;
	}
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var ent : CGameplayEntity;
	
		if(collidingComponent)
		{
			ent = (CGameplayEntity)collidingComponent.GetEntity();
			if(ent)
				frostEntity.Collided(ent);
		}
	}
}