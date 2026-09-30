/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_WitchHypnotized extends W3CriticalEffect
{
	var customCameraStackIndex 			: int;
	var fxEntity 							: CEntity;
	var envID 							: int;
	
		default criticalStateType 	= ECST_Hypnotized;
		default effectType 			= EET_WitchHypnotized;
		default resistStat 			= CDS_WillRes;
		default attachedHandling 	= ECH_Abort;
		default onHorseHandling 	= ECH_Abort;
		default isNegative 			= false;
		default isNeutral 			= true;
	
	public function CacheSettings()
	{
		super.CacheSettings();
		
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Movement);
		blockedActions.PushBack(EIAB_Fists);
		blockedActions.PushBack(EIAB_Jump);
		
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_Dodge);
		blockedActions.PushBack(EIAB_Roll);
		blockedActions.PushBack(EIAB_SwordAttack);
		blockedActions.PushBack(EIAB_Parry);
		
		blockedActions.PushBack(EIAB_Explorations);
		blockedActions.PushBack(EIAB_Counter);
		blockedActions.PushBack(EIAB_LightAttacks);
		blockedActions.PushBack(EIAB_HeavyAttacks);
		blockedActions.PushBack(EIAB_SpecialAttackLight);
		blockedActions.PushBack(EIAB_SpecialAttackHeavy);
		blockedActions.PushBack(EIAB_QuickSlots);
	}
	
	event OnUpdate(deltaTime : float)
	{
		
		
		
			
		super.OnUpdate(deltaTime);
	}
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var customCameraParams : SCustomCameraParams;
		var actor : CActor;
		var template : CEntityTemplate;
		var environment : CEnvironmentDefinition;		
		
		super.OnEffectAdded(customParams);
		
		if ( this.isOnPlayer )
		{
			
			actor = (CActor)GetCreator();
			customCameraParams.source = actor;
			customCameraParams.useCustomCamera = true;
			customCameraParams.cameraParams.enums.Resize(2);
			customCameraParams.cameraParams.enums[0].enumType = 'ECustomCameraType';
			customCameraParams.cameraParams.enums[0].enumValue = CCT_CustomController;
			customCameraParams.cameraParams.enums[1].enumType = 'ECustomCameraController';
			customCameraParams.cameraParams.enums[1].enumValue = CCC_NoTarget;
			
			thePlayer.AddCustomOrientationTarget(OT_Camera, 'HypnotizedEffect');
			
			template = (CEntityTemplate)LoadResource("bies_fx");
			fxEntity = theGame.CreateEntity(template,thePlayer.GetWorldPosition());
			if ( fxEntity )
			{
				fxEntity.CreateAttachment(thePlayer);
				
				
				fxEntity.DestroyAfter(duration);
			}
			
			environment = (CEnvironmentDefinition)LoadResource("env_bies_hypnotize");
    		envID = ActivateEnvironmentDefinition( environment, 1000, 1, 1.f );
    		theGame.SetEnvironmentID(envID);
    		
    		if(actor)
				actor.SignalGameplayEvent('HypnotizeAdded');
		}
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		
		if(fxEntity)
			fxEntity.DestroyAfter(timeLeft);
	}
	
	event OnEffectRemoved()
	{
		var customCameraParams : SCustomCameraParams;
		var actor : CActor;
		
		if ( isOnPlayer )
		{
			
			
			DeactivateEnvironment( envID, 1 );
			actor = (CActor)GetCreator();
			if(actor)
				actor.SignalGameplayEvent('HypnotizeRemoved');
			
			thePlayer.RemoveCustomOrientationTarget( 'HypnotizedEffect' );
			
			
		}
		super.OnEffectRemoved();
	}	
}