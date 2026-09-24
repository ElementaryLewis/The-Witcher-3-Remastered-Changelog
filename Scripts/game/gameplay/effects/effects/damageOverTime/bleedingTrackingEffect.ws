/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_BleedingTracking extends W3DamageOverTimeEffect
{	
	private var bloodTemplate : CEntityTemplate;
	private var bloodSpawnTimer : float;
	private const var BLOOD_SPAWN_DELAY_MIN, BLOOD_SPAWN_DELAY_MAX : int;			
	
	default BLOOD_SPAWN_DELAY_MIN = 2;
	default BLOOD_SPAWN_DELAY_MAX = 3;
	default effectType = EET_BleedingTracking;
	default resistStat = CDS_BleedingRes;
	
	public function OnDamageDealt(dealtDamage : bool)
	{
		
		if(!dealtDamage)
		{
			shouldPlayTargetEffect = false;
			StopTargetFX();
		}
		else
		{
			shouldPlayTargetEffect = true;
			PlayTargetFX();
		}		
	}
	
	event OnUpdate(dt : float)
	{
		var pos, posTo, posUp, tempV, posDown : Vector;
		
		super.OnUpdate(dt);
		
		bloodSpawnTimer -= dt;
		if(bloodSpawnTimer <= 0)
		{
			
			pos = target.GetWorldPosition();
			posUp = pos;
			posUp.Z += 0.2;		
			posDown = pos;
			posDown.Z -= 50;	
			
			if(theGame.GetWorld().StaticTrace( posUp, posDown, posTo, tempV))
			{
				posTo.Z += 0.05;	
			}
			else
			{
				posTo = posUp;
			}

			theGame.CreateEntity(bloodTemplate, posTo, EulerAngles(0, RandF() * 360, 0), , , , PM_Persist);
		
			
			bloodSpawnTimer = RandRangeF(BLOOD_SPAWN_DELAY_MAX, BLOOD_SPAWN_DELAY_MIN);
		}
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		bloodTemplate = (CEntityTemplate)LoadResource("tracking_bolt_blood");
		bloodSpawnTimer = 0;
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		bloodTemplate = (CEntityTemplate)LoadResource("tracking_bolt_blood");
		bloodSpawnTimer = 0;
	}
}