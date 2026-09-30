/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EBackgroundNPCWork_Single
{
	EBNWS_None,
	EBNWS_Brush,
	EBNWS_Sit,	
	EBNWS_SitPipe,
	EBNWS_Spyglass,		
	EBNWS_StandWall,
	EBNWS_Tired,
	EBNWS_WarmUp,	
	EBNWS_PlayingFlute,
	EBNWS_SitSquat,
	EBNWS_DrunkStandRope,
	EBNWS_Crouch,
	EBNWS_WriteList,
	EBNWS_GuardStand,
	EBNWS_Rowing,
	EBNWS_StandTalk1,
	EBNWS_StandTalk2,
	EBNWS_StandTalk3,
	EBNWS_SitDrink,
	EBNWS_SitEat,
	EBNWS_Kneel,
	EBNWS_SitGroundHurt,
	EBNWS_Scout,
	EBNWS_Puke,
	EBNWS_Sex,
	EBNWS_Fishing
}


class W3NPCBackground extends CGameplayEntity
{
	public editable var work : EBackgroundNPCWork_Single;					
	private var parentPairedBackgroundNPCEntity : W3NPCBackgroundPair;		
	private var isWorkingSingle : bool;										
	
		default isWorkingSingle = false;
	
	event OnSpawned(spawnData : SEntitySpawnData)
	{
		
		if(!parentPairedBackgroundNPCEntity)
		{
			isWorkingSingle = true;
			SetBehaviorVariable( 'WorkTypeEnum_Single',(int)work);
		}
	}
	
	public function SetParentPairedBackgroundNPCEntity(ent : W3NPCBackgroundPair)
	{
		parentPairedBackgroundNPCEntity = ent;
		if(isWorkingSingle)
		{
			isWorkingSingle = false;
			SetBehaviorVariable( 'WorkTypeEnum_Single',(int)EBNWS_None);
		}
	}
}