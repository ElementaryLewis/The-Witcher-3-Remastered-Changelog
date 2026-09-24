/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function IsRequiredAttitudeBetween(one, two : CEntity, hostile : bool, optional neutral : bool, optional friendly : bool) : bool
{
	var att : EAIAttitude;
	
	att = GetAttitudeBetween(one, two);
	return (att == AIA_Hostile && hostile) || (att == AIA_Neutral && neutral) || (att == AIA_Friendly && friendly);
}


function GetAttitudeBetween(one, two : CEntity) : EAIAttitude
{
	var act1, act2 : CActor;

	if(one && two)
	{
		if( (CPlayer)one && (CPlayer)two )
		{
			return AIA_Friendly;
		}
		else
		{ 
			act1 = (CActor)one;
			act2 = (CActor)two;
			
			if(act1 && act2)
				return act1.GetAttitude(act2);
		}
	}
	
	
	return AIA_Neutral;
}

function GetActorsInRange(center : CNode, range : float, optional maxResults : int, optional tag : name, optional onlyAlive : bool) : array <CActor>
{
	var flags : int;
	var actors : array<CActor>;
	var entities : array<CGameplayEntity>;
	var act : CActor;

	
	if ( maxResults == 0 )
	{
		maxResults = 1000000;
	}

	if ( onlyAlive )
	{
		FindGameplayEntitiesInSphere( entities, center.GetWorldPosition(), range, maxResults, tag, FLAG_OnlyAliveActors );
	}
	else
	{
		FindGameplayEntitiesInSphere( entities, center.GetWorldPosition(), range, maxResults, tag, FLAG_OnlyActors );
	}

	ArrayOfActorsAppendArrayOfGameplayEntities( actors, entities );
	return actors;
}

function GetNonFriendlyGameplayEntitiesInRange(center : CNode, range : float, attitudeReferenceActor : CActor, optional maxResults : int, optional tag : name) : array<CGameplayEntity>
{
	var ents : array<CGameplayEntity>;
	
	if ( maxResults == 0 )
	{
		maxResults = 1000000;
	}
	
	FindGameplayEntitiesInSphere( ents, center.GetWorldPosition(), range, maxResults, tag, FLAG_Attitude_Neutral | FLAG_Attitude_Hostile, attitudeReferenceActor );
	return ents;
}


import function FindGameplayEntitiesInRange(out			entities  		: array< CGameplayEntity >,
														center    		: CNode,
														range     		: float,
														maxResults		: int,
											optional	tag       		: name, 
											optional	queryFlags		: int,  
											optional	target			: CGameplayEntity,  
											optional	className		: name 
											);



import function FindGameplayEntitiesInSphere(	out				entities  		: array< CGameplayEntity >,
																point    		: Vector,
																range     		: float,
																maxResults		: int,
													optional	tag       		: name, 
													optional	queryFlags		: int,  
													optional	target			: CGameplayEntity,   
													optional	className		: name 
												);

import function FindGameplayEntitiesInCylinder(	out				entities  		: array< CGameplayEntity >,
																point    		: Vector,
																range     		: float,
																height     		: float,
																maxResults		: int,
													optional	tag       		: name, 
													optional	queryFlags		: int,  
													optional	target			: CGameplayEntity,   
													optional	className		: name 
												);


import function FindGameplayEntitiesInCone(	out					entities  		: array< CGameplayEntity >,
																point    		: Vector,
																coneDir			: float,
																coneAngle		: float,
																range     		: float,
																maxResults		: int,
													optional	tag       		: name, 
													optional	queryFlags		: int,  
													optional	target			: CGameplayEntity,   
													optional	className		: name 
												);
												
import function FindGameplayEntitiesInBox(	out					entities  		: array< CGameplayEntity >,
																point    		: Vector,																
																boxLS  			: Box, 
																maxResults		: int,
													optional	tag       		: name, 
													optional	queryFlags		: int,  
													optional	target			: CGameplayEntity,   
													optional	className		: name 
												);

import function FindGameplayEntitiesCloseToPoint(	out			entities  		: array< CGameplayEntity >,
																point    		: Vector,
																range     		: float,
																maxResults		: int,
													optional	tag       		: name, 
													optional	queryFlags		: int,  
													optional	target			: CGameplayEntity,  
													optional	className		: name 
												);

import function FindActorsAtLine(			startPos    			: Vector,
											endPos    				: Vector,
											radius     				: float,
								out 		result 					: array<SRaycastHitResult>,
								optional 	collisionGroupsNames 	: array<name>
											);