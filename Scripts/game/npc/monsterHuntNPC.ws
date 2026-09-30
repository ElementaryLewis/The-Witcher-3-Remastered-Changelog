/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MonsterHuntNPC extends CNewNPC
{
	const var MONSTER_HUNT_TARGET_TAG : name; default MONSTER_HUNT_TARGET_TAG = 'MonsterHuntTarget';
	
	private var bossBarOn : bool;
	saved var musicOn : bool;
	editable var displayBossBar : bool;	
	editable saved var switchMusic : bool;
	editable saved var questFocusSoundOnSpawn: bool;
	
	editable var dontTagForAchievement : bool;
	editable var disableDismemberment  : bool;
	
	editable var combatMusicStartEvent : string;
	editable var combatMusicStopEvent  : string;
	
	editable var associatedInvestigationAreasTag : name;
	saved var investigationAreasProcessed : bool;
	
	default displayBossBar 		   = true;
	default questFocusSoundOnSpawn = true;
	default switchMusic 		   = true;
	default disableDismemberment   = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var tags : array< name >;
		super.OnSpawned( spawnData );
		
		if ( theGame.IsActive() )
		{
			tags = GetTags();
			
			if ( !HasTag( MONSTER_HUNT_TARGET_TAG ) && !dontTagForAchievement )
			{
				tags.PushBack( MONSTER_HUNT_TARGET_TAG );
			}
			
			if( !HasTag( 'HideHealthBarModule' ) && displayBossBar )
			{
				tags.PushBack( 'HideHealthBarModule' );
			}
			
			SetTags( tags );
		}
		
		
		
		AddTimer( 'MonsterHuntNPCBossBarTimer', 0.5f, true);
		
		if( questFocusSoundOnSpawn )
			SetFocusModeSoundEffectType( FMSET_Red );
			
		
		if( disableDismemberment )
		{
			if( !HasAbility( 'DisableDismemberment' ) )
			{
				AddAbility( 'DisableDismemberment', false );
			}
		}
	}
	
	event OnDestroyed()
	{
		super.OnDestroyed();
		
		ShowMonsterHuntBossFightIndicator( false );
		SwitchMonsterHuntCombatMusic( false );
		RemoveTimer( 'MonsterHuntNPCBossBarTimer' );
		
	}

	event OnDeath( damageAction : W3DamageAction )
	{
		super.OnDeath( damageAction );
		
		ShowMonsterHuntBossFightIndicator( false );
		SwitchMonsterHuntCombatMusic( false );
		RemoveTimer( 'MonsterHuntNPCBossBarTimer' );
		
	}

	timer function MonsterHuntNPCBossBarTimer( delta : float , id : int)
	{
		
		if( ( IfCanSeePlayer() || thePlayer.GetDisplayTarget() == this ) && !bossBarOn )
		{
			if( GetAttitudeBetween( thePlayer, this ) == AIA_Hostile )
			{
				if(displayBossBar)
				{
					ShowMonsterHuntBossFightIndicator( true );
				}
				
				SwitchAssociatedInvestigationAreas( false );
				SwitchMonsterHuntCombatMusic( true );
			}
		}
		else
		{
			if( VecDistance( this.GetWorldPosition(), thePlayer.GetWorldPosition() ) >= 45.0f || GetAttitudeBetween( thePlayer, this ) != AIA_Hostile )
			{
				if(displayBossBar)
				{
					ShowMonsterHuntBossFightIndicator( false );
				}
				
				SwitchMonsterHuntCombatMusic( false );
			}
			
		}
		
	}
	
	private function ShowMonsterHuntBossFightIndicator( enable : bool )
	{
		var hud : CR4ScriptedHud;	
		var bossFocusModule : CR4HudModuleBossFocus;
		
		hud = (CR4ScriptedHud)theGame.GetHud();	
		
		if(hud)
		{
			bossFocusModule = (CR4HudModuleBossFocus)hud.GetHudModule("BossFocusModule");
			
			if(bossFocusModule)
			{
				if(enable && !bossBarOn)
				{			
					bossFocusModule.ShowBossIndicator( true, '', this );
					bossBarOn = true;
					return;
				}
				else if(!enable && bossBarOn)
				{
					bossFocusModule.ShowBossIndicator( false, '' );
					bossBarOn = false;
				}
			}
		}
	}
	
	public function SwitchMonsterHuntCombatMusic( enable : bool )
	{
		if( !switchMusic )
			return;
		
		if( enable )
		{
			theSound.SoundEvent( combatMusicStartEvent );
			musicOn = true;
		}
		else
		{
			if( musicOn )
			{
				theSound.SoundEvent( combatMusicStopEvent );
				musicOn = false;
			}
		}
	}
	
	public function GetIsBossbarOn() : bool
	{
		return bossBarOn;
	}
	

	private function SwitchAssociatedInvestigationAreas( enable : bool )
	{
		var entitesList : array<CEntity>;
		var area		: W3MonsterHuntInvestigationArea;
		var i 			: int;
		
		if( !IsNameValid( associatedInvestigationAreasTag ) || investigationAreasProcessed )
			return;
			
		theGame.GetEntitiesByTag( associatedInvestigationAreasTag, entitesList );
		
		for(i=0; i<entitesList.Size(); i+=1)
		{
			area = ( W3MonsterHuntInvestigationArea ) entitesList[i];
			
			if( area )
			{
				area.SetInvestigationAreaEnabled( enable, true );
			}
		}
		
		investigationAreasProcessed = true;
	}
	
}