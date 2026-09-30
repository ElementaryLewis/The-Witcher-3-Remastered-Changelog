/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Hypnotized extends W3CriticalEffect
{
	var customCameraStackIndex 			: int;	
	var envID 							: int;
	var fxEntity 						: CEntity;
	var gameplayVisibilityFlag			: bool;
	
		default criticalStateType 	= ECST_Hypnotized;
		default effectType 			= EET_Hypnotized;
		default resistStat 			= CDS_WillRes;
		default attachedHandling 	= ECH_Abort;
		default onHorseHandling 	= ECH_Abort;
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Sprint);		
		blockedActions.PushBack(EIAB_Counter);		
	}
	
	event OnUpdate(deltaTime : float)
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		
		if(isOnPlayer && GetCreator() && !GetCreator().IsAlive())
			timeLeft = 0;
		
		
		if(isOnPlayer && witcher.HasBuff( EET_Cat ) && witcher.GetPotionBuffLevel( EET_Cat ) >= 2 )
			timeLeft = 0;
		
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
			thePlayer.HardLockToTarget( false );
			actor = (CActor)GetCreator();
			gameplayVisibilityFlag = actor.GetGameplayVisibility();
			actor.SetGameplayVisibility( false );
			
			
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
			actor.SetGameplayVisibility( gameplayVisibilityFlag );
			if(actor)
				actor.SignalGameplayEvent('HypnotizeRemoved');
			
			this.GetCreator().StopEffect( 'third_eye_fx' );
			
			thePlayer.RemoveCustomOrientationTarget( 'HypnotizedEffect' );			
		}
		super.OnEffectRemoved();
	}	
}