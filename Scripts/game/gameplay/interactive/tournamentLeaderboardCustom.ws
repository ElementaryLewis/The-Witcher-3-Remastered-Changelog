/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SLeaderBoardData
{
	saved var competitor : string;
	saved var points 	 : int;
}


statemachine class W3LeaderboardCustom  extends W3Poster
{

	editable saved var m_competitors		 : array<SLeaderBoardData>;
	editable var m_pointSymbolStringKey 	 : string;
	editable var m_displayPointsNumerically  : bool;
	editable var m_bottom_padding : int;
	editable var m_left_padding : int;
	
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		GenerateDescription();
		
		super.OnInteraction( actionName, activator );
	}	
	
	
	private function GenerateDescription()
	{
		var i : int;
		var size : int;
		
		descriptionGenerated = true;
		
		description = "";
		
		size = m_competitors.Size();
		
		for( i=0; i < size; i+= 1 )
		{
			description += AddLeftPadding() + GetLocStringByKeyExt( m_competitors[i].competitor ) + " " + AddPointMarkersString( m_competitors[i].points ) +"<br>";	
		}
		
		if( m_bottom_padding > 0 )
		{
			description +=  AddBottomPadding();
		}
		
	}
	
	
	private function AddPointMarkersString( points : int ) : string
	{
		var i : int;
		var pointsString : string;
		
		if( m_displayPointsNumerically )
		{
			return points;
		}
		
		while( i < points )
		{
			pointsString += " "+ GetLocStringByKeyExt( m_pointSymbolStringKey ) +" ";
			i+=1;
		}
		
		return pointsString;
	}
	
	
	private function AddBottomPadding() : string
	{
		var i : int;
		var padding : string;
		
		while( i < m_bottom_padding )
		{
			padding += "<br>";
			i+=1;
		}
		
		return padding;
	}	

	
	private function AddLeftPadding() : string
	{
		var i : int;
		var padding : string;
		
		if( m_left_padding < 0 )
		{
			return "";
		}
		
		while( i < m_left_padding )
		{
			padding += "  ";
			i+=1;
		}
		
		return padding;
	}	
	
	
	public function AddPointToCompetitor( editedComptetitor : string, points : int )
	{
		var i : int;
		var size : int;
		var newEntry : SLeaderBoardData;
		
		size = m_competitors.Size();
		
		for( i=0; i < size; i+= 1 )
		{
			if( editedComptetitor == m_competitors[i].competitor )
			{
				m_competitors[i].points += points;
				return;
			}
		}	
		
		newEntry.competitor =  editedComptetitor;
		newEntry.points 	=  points;
		
		m_competitors.PushBack( newEntry );
		
	}
}