/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
latent quest function BossFight_Witches_WaitForWitchesToBeHit( witch1tag : string, witch2tag : string, witch3tag : string, desiredTimeWindow : float )
{
	var res									: bool;
	var fact1, fact2, fact3 				: string;
	var fact1alt, fact2alt, fact3alt 		: string;
	var fact1Found, fact2Found, fact3Found 	: bool;
	var tempTime 							: float;
	var timeWindow 							: float;
	var factsCount 							: int;
	
	fact1 = witch1tag + "_phantom_hit";
	fact1alt = "actor_" + witch1tag + "_was_killed";
	fact2 = witch2tag + "_phantom_hit";
	fact2alt = "actor_" + witch2tag + "_was_killed";
	fact3 = witch3tag + "_phantom_hit";
	fact3alt = "actor_" + witch3tag + "_was_killed";
	
	if ( desiredTimeWindow <= 0 )
		timeWindow = theGame.GetEngineTimeAsSeconds() + 2.0;
	else
		timeWindow = theGame.GetEngineTimeAsSeconds() + desiredTimeWindow;
	
	factsCount = 0;
	
	while ( true )
	{
		tempTime = theGame.GetEngineTimeAsSeconds();
		if ( !fact1Found && ( FactsQueryLatestValue(fact1) >= 1 || FactsDoesExist(fact1alt) ) )
		{
			fact1Found = true;
			factsCount += 1;
		}
		if ( !fact2Found && ( FactsQueryLatestValue(fact2) >= 1 || FactsDoesExist(fact2alt) ) )
		{
			fact2Found = true;
			factsCount += 1;
		}
		if ( !fact3Found && ( FactsQueryLatestValue(fact3) >= 1 || FactsDoesExist(fact3alt) ) )
		{
			fact3Found = true;
			factsCount += 1;
		}
		
		if ( factsCount >= 3 )
		{
			break;
		}
		else if ( timeWindow < tempTime && !res )
		{
			fact1Found = fact2Found = fact3Found = false;
			FactsAdd( 'witches_hypnotized', 1, -1 );
			res = true;
		}
		
		SleepOneFrame();
	}
	
	while( thePlayer.IsInCombatAction_SpecialAttack() )
	{
		SleepOneFrame();
	}
}

latent quest function BossFight_Witches_ClosePlayerInCage( cageTag : name, close : bool, regenerateHealthOnPerc : float, regenDuration : float, regenValuePerc : float )
{
	var cage 				: CEntity;
	var entityTemplate 		: CEntityTemplate;
	var spawnedEntity 		: CEntity;
	var tags 				: array<name>;
	var i					: int;
	var healthPerc			: float;
	var dotValue			: float;
	var witches				: array<CActor>;
	var params 				: SCustomEffectParams;
	
	cage = theGame.GetEntityByTag(cageTag);
	
	theGame.GetActorsByTag( 'q111_witch', witches );
	
	entityTemplate = (CEntityTemplate)LoadResource("witches_cage");
	
	if ( close )
	{
		params.effectType = EET_Immobilized;
		params.creator = witches[0];
		params.sourceName = "q111_witch_immobilize";
		params.duration = 5;
		
		thePlayer.AddEffectCustom(params);
		
		while ( thePlayer.IsCurrentlyDodging() )
		{
			SleepOneFrame();
		}
	}
	
	if( !cage && close )
	{
		if ( entityTemplate )
			cage = theGame.CreateEntity( entityTemplate, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );
		if ( cage )
			cage.ApplyAppearance("1_roots_on");
		tags = cage.GetTags();
		tags.PushBack('q111_witches_cage');
		cage.SetTags(tags);
		cage.PlayEffect( 'trap' );
		
		Sleep( 1.0 );
		
		thePlayer.RemoveBuff( EET_Immobilized, "q111_witch_immobilize" );
		
		if ( regenerateHealthOnPerc <= 0 )
		{
			regenerateHealthOnPerc = 0.5;
		}
		
		if ( witches.Size() > 0 )
		{
			for ( i = 0; i < witches.Size(); i += 1 )
			{
				healthPerc = witches[i].GetStatPercents( BCS_Essence );
				if ( healthPerc < regenerateHealthOnPerc )
				{
					if ( regenDuration > 0 )
					{
						params.effectType = EET_BoostedEssenceRegen;
						params.creator = NULL;
						if ( regenValuePerc > 0 )
							params.effectValue.valueMultiplicative = regenValuePerc;
						params.sourceName = "q111_witch_regen";
						params.duration = regenDuration;
						
						witches[i].AddEffectCustom(params);
					}
					else
					{
						witches[i].AddEffectDefault( EET_BoostedEssenceRegen, NULL, "q111_witch_regen" );
					}
				}
				
			}
			
			params.effectType = EET_Bleeding;
			params.creator = NULL;
			params.sourceName = "q111_witch_bleeding";
			params.duration = regenDuration;
			dotValue = thePlayer.GetHealthPercents() + 0.35;
			dotValue /= regenDuration;
			params.effectValue.valueMultiplicative = dotValue;
			thePlayer.AddEffectCustom(params);
		}
	}
	else if ( cage && !close )
	{
		for ( i = 0; i < witches.Size(); i += 1 )
		{
			witches[i].RemoveAllBuffsOfType( EET_BoostedEssenceRegen );
			
		}
		cage.ApplyAppearance( "2_roots_off" );
		cage.DestroyAfter( 1.0 );
	}
}

quest function BossFight_Witches_ApplyHypnotizeEffect( duration : float )
{
	var params : SCustomEffectParams;
	
	if ( duration > 0 )
	{
		params.effectType = EET_WitchHypnotized;
		params.creator = NULL;
		params.sourceName = "WitchHypnotize";
		params.duration = duration;
		
		thePlayer.AddEffectCustom(params);
	}
	else
	{
		thePlayer.AddEffectDefault( EET_WitchHypnotized, NULL, "WitchHypnotize" );
	}
}

quest function BossFight_WH_Mage_TeleportToNode( mageTag : name, nodeTag : name )
{
	var mage : CActor;
	
	mage = theGame.GetActorByTag(mageTag);
	
	if( mage )
	{
		mage.SignalGameplayEventParamCName('ChangeNextTeleportPoint',nodeTag);
	}
}

latent quest function CombatStageChangeLatent( npcsTag : name, stage : ENPCFightStage )
{
	var i, size : int;
	var npcsArray : array<CNewNPC>;
	
	theGame.GetNPCsByTag( npcsTag, npcsArray );
	
	size = npcsArray.Size();
	
	while( true )
	{
		for( i = 0; i < size; i += 1 )
		{
			npcsArray[i].ChangeFightStage( stage );
		}
		Sleep( 0.1 );
	}
}