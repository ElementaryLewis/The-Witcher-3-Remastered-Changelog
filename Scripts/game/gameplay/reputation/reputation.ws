/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3FactionReputationPoints
{
	saved var currentReputationPoints		: int;
	saved var negativeReputationPoints	 	: int;
	
	default currentReputationPoints = 50;
	default negativeReputationPoints = 0;
}



enum EReputationLevel
{
	RL_Hated,
	RL_Disliked,
	RL_Neutral,
	RL_Liked,
	RL_Respectable
	
}

enum EFactionName
{
	FN_NoMansLandPoor = 0,
	FN_NovigradNobles = 1,
	FN_SkelligeUndvik = 2,
	FN_MaxEnum = 3,
}

class W3Reputation
{
	saved var factionReputations	: array< W3FactionReputationPoints >;
	var factionName 				: EFactionName;
			
	function Initialize()
	{
		if ( factionReputations.Size() == 0 )
		{
			factionReputations.PushBack( new W3FactionReputationPoints in this );
			factionReputations.PushBack( new W3FactionReputationPoints in this );
			factionReputations.PushBack( new W3FactionReputationPoints in this );
		}
	}
	
	
	function SetFactionName( fName : EFactionName ) 
	{
		fName = factionName; 
	}
	
	function GetFaction( i : int ) : EFactionName
	{
		if ( i == 0 )
		{
			factionName = FN_NoMansLandPoor;
		}
		else if ( i == 1 )
		{
			factionName = FN_NovigradNobles;
		}
		else if ( i == 2 )
		{
			factionName = FN_SkelligeUndvik;
		}
		
		return factionName;
	}
	
	function GetReputationPoints ( fName : EFactionName ) : int
	{
		var currentRepPoints : int; 

		currentRepPoints = factionReputations[ fName ].currentReputationPoints;
		return currentRepPoints;
	}
	function GetNegativeReputationPoints ( fName :EFactionName ) : int
	{
		var negativeRepPoints : int;
		
		negativeRepPoints = factionReputations[ fName ].negativeReputationPoints;
		return negativeRepPoints;
	}
	
	
	function ChangeReputationAmongFaction( factionName : EFactionName, addAmount : int )
	{
		factionReputations[ factionName ].currentReputationPoints += addAmount;
		
		if ( addAmount < 0 )
		{
			factionReputations[ factionName ].negativeReputationPoints += addAmount;  
		}

		if ( factionReputations[ factionName ].currentReputationPoints < 0 )
		{
			factionReputations[ factionName ].currentReputationPoints = 0;
		}
		else if ( factionReputations[ factionName ].currentReputationPoints > 100 )
		{
			factionReputations[ factionName ].currentReputationPoints = 100;
		}
	}
		
	function GetReputationBonuses( reputationLevels : EReputationLevel, out buyPriceMult : float, out sellPriceMult : float )
	{	
		switch( reputationLevels )
		{
			case RL_Hated :
			{
				buyPriceMult = 1.3;
				sellPriceMult = 0.3;
				break;
			}
			case RL_Disliked :
			{
				buyPriceMult = 1.15;
				sellPriceMult = 0.85;
				break;
			}
			case RL_Neutral :
			{
				buyPriceMult = 1;
				sellPriceMult = 1;
				break;
			}
			case RL_Liked :
			{
				buyPriceMult = 0.85;
				sellPriceMult = 1.15;
				break;
			}
			case RL_Respectable :
			{
				buyPriceMult = 0.7;
				sellPriceMult = 1.3;
				break;
			}
		}
						
	}
	
	function GetReputationLevel( factionName : EFactionName ) : EReputationLevel
	{
		var reputationLevel 	: EReputationLevel;
		var reputationPoints 	: int;
		
		reputationPoints = factionReputations[ factionName ].currentReputationPoints;
				
		if ( reputationPoints <= 15 )
		{
			reputationLevel = RL_Hated;
		}
		else if ( reputationPoints <= 40 )
		{
			reputationLevel = RL_Disliked;
		}
		else if ( reputationPoints <= 60 )
		{
			reputationLevel = RL_Neutral;
		}
		else if ( reputationPoints <= 80 )
		{
			reputationLevel = RL_Liked;
		}
		else
		{
			reputationLevel = RL_Respectable;
		}
		return reputationLevel;
	}
		
	function ResetNegativeReputationPoints( factionName : EFactionName )
	{
		factionReputations[ factionName ].currentReputationPoints -= factionReputations[ factionName ].negativeReputationPoints;
		factionReputations[ factionName ].negativeReputationPoints = 0;
	}
}
	
	
	function GetPlayerReputationManager() : W3Reputation
	{
		return ( (W3PlayerWitcher)thePlayer ).reputationManager;
	}
	
	exec function reptest( i : int ) 
	{
		var facName : EFactionName = GetPlayerReputationManager().GetFaction( i ); 
		var repLevel : EReputationLevel = GetPlayerReputationManager().GetReputationLevel( facName );
		
		LogChannel( 'Reputation', "Actual reputation level among " + facName + " is " + repLevel );
	}
	
	exec function faction( i : int )
	{
		var facName : EFactionName = GetPlayerReputationManager().GetFaction( i );

		if ( i >= FN_MaxEnum )
		{
			LogChannel('Reputation', "There's no such faction.");
		}
		else
		{
			GetPlayerReputationManager().SetFactionName( facName );
			LogChannel( 'Reputation', "Chosen faction: " + facName );
		}
	}
	
	exec function reputationpoints( i : int ) 
	{
		var facName 	: EFactionName = GetPlayerReputationManager().GetFaction( i );
		var repPoints	: int = GetPlayerReputationManager().GetReputationPoints( facName );
		
		GetPlayerReputationManager().SetFactionName( facName );
		
		LogChannel('Reputation', "Current reputation points among " + facName + ": " + repPoints );
	}
	
	exec function addreppoints( i : int, points : int  )
	{
		var facName 			: EFactionName = GetPlayerReputationManager().GetFaction( i );
		var repLevel 			: EReputationLevel;
		var repPoints 			: int; 
		var negPoints			: int;
		var buyPriceMultiplier	: float;
		var sellPriceMultiplier	: float;

		GetPlayerReputationManager().SetFactionName( facName );
		
		GetPlayerReputationManager().ChangeReputationAmongFaction( facName, points );
		repLevel = GetPlayerReputationManager().GetReputationLevel( facName );
		repPoints = GetPlayerReputationManager().GetReputationPoints( facName );
		negPoints = GetPlayerReputationManager().GetNegativeReputationPoints( facName );
		
		GetPlayerReputationManager().GetReputationBonuses( repLevel, buyPriceMultiplier, sellPriceMultiplier );
		
		LogChannel( 'Reputation', "The reputation points among " + facName + " is: " + repPoints + ". The reputation level is " + repLevel );
		LogChannel( 'Reputation', "Buy price multiplier: " + buyPriceMultiplier + ", sell price multiplier: " + sellPriceMultiplier + "." );
		
		if ( negPoints != 0 )
		{
			LogChannel( 'Reputation', "The negative reputation points: " + negPoints );
		}
		
		
	}
	
	exec function resetnegativepoints( i : int ) 
	{
		var facName 			: EFactionName = GetPlayerReputationManager().GetFaction( i );
		var negPoints 			: int = GetPlayerReputationManager().GetNegativeReputationPoints( facName );
		var remainingNegPoints	: int;
				
		if ( negPoints == 0 )
		{
			LogChannel( 'Reputation', "There were no negative reputation points." );
		}
		else
		{
			GetPlayerReputationManager().ResetNegativeReputationPoints( facName );
			remainingNegPoints = GetPlayerReputationManager().GetNegativeReputationPoints( facName );
			LogChannel( 'Reputation', "Negative points were successfully subtracted. Actual amount is: " + remainingNegPoints );
		}
	}
	
	exec function bonusvalue ( i : int ) 
	{
		var facName 			: EFactionName = GetPlayerReputationManager().GetFaction( i );
		var repPoints			: int = GetPlayerReputationManager().GetReputationPoints( facName );
		var repLevel 			: EReputationLevel = GetPlayerReputationManager().GetReputationLevel( facName );
		var buyPriceMultiplier	: float;
		var sellPriceMultiplier	: float;
		
		GetPlayerReputationManager().GetReputationBonuses( repLevel, buyPriceMultiplier, sellPriceMultiplier );
		
		LogChannel( 'Reputation', "Buy price multiplier: " + buyPriceMultiplier + ", sell price multiplier: " + sellPriceMultiplier + "." );
	} 
	