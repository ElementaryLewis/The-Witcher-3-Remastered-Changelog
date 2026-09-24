/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3MusicBandActivatorArea extends CEntity
{
	editable var musiciansTag 				: name; 				default musiciansTag = 'musician';
	editable var interiorSoundEmitter		: CEntityTemplate;
	editable var exteriorSoundEmitter		: CEntityTemplate;
	editable var exterior					: bool; 				default exterior = true;
	editable var minimalNumberOfMusicions 	: int; 					default minimalNumberOfMusicions = 4;
	
	hint minimalNumberOfMusicions = "...active (at Work) to start playing music";
	
	var activeSoundEmitter				: CEntity;
	var activeMusician					: CEntity;
	var activeMusicians					: array<CEntity>;
	var activeArea						: CTriggerAreaComponent;
	var  jobTreeType 					: EJobTreeType;
			 
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var playerEntity 	: CPlayer;
		
		playerEntity = (CPlayer)activator.GetEntity();
		if( playerEntity )
		{
			activeArea = area;
			Update(0.f,0);
			AddTimer ( 'Update', 0.5f, true );
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var playerEntity 	: CPlayer;
		
		playerEntity = (CPlayer)activator.GetEntity();
		
		if( playerEntity )
		{
			StopMusic ();
			RemoveTimer ( 'Update' );
		}
	}
	
	event OnDetaching()
	{
		StopMusic ();
	}
	
	function StartMusic()
	{
		var soundEmitterPos : Vector;
		var soundEmitterRot	: EulerAngles;
		
		soundEmitterPos = activeMusician.GetWorldPosition();
		soundEmitterRot = activeMusician.GetWorldRotation();
		
		if ( exterior )
		{
			activeSoundEmitter = theGame.CreateEntity( exteriorSoundEmitter, soundEmitterPos, soundEmitterRot );
		}
		else
		{
			activeSoundEmitter = theGame.CreateEntity( interiorSoundEmitter, soundEmitterPos, soundEmitterRot );
		}
	}
	
	function StopMusic ()
	{
		if ( activeSoundEmitter )
		{
			activeSoundEmitter.Destroy();
		}
	}
	
	function UpdateActiveMusicians() : bool
	{
		var entitites		: array <CGameplayEntity>;
		var	i				: int;
		var activeMusicions : int;
		var npc				: CNewNPC;
		
		activeMusicians.Clear();
		
		
		activeArea.GetGameplayEntitiesInArea( entitites, 50.0f, true );
		for ( i=0; i < entitites.Size(); i+=1 )
		{
			npc = (CNewNPC)entitites[i];
			if ( npc && npc.HasTag(musiciansTag) && npc.IsAtWork())
			{
				jobTreeType = npc.GetCurrentJTType();
				if ( jobTreeType == EJT_PlayingMusic )
				{
					activeMusicians.PushBack( entitites[i] );
					activeMusicions += 1;
				}
			}
		}
		
		if ( activeMusicions < minimalNumberOfMusicions )
		{
			return false;
		}
		
		return true;
	}
	
	timer function Update( timeDelta : float, id : int )
	{
		var shouldMusicBePlayed : bool;
		
		shouldMusicBePlayed = UpdateActiveMusicians();
		
		if ( !shouldMusicBePlayed && activeSoundEmitter  )
		{
			StopMusic();
		}
		else if ( shouldMusicBePlayed && !activeSoundEmitter )
		{
			activeMusician = activeMusicians[0];
			if ( activeMusician )
			{
				StartMusic();
			}
		}
	}
}