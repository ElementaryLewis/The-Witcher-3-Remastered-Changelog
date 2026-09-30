/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4KinectSpeechRecognizerListenerScriptProxy extends CObject
{

	import final function IsSupported() : bool;
	import final function IsEnabled() : bool;
	import final function SetEnabled( enable: bool );

	private function OnListenerRegistered() : void
	{
		LogChannel( 'Kinect', "Kinect - CR4KinectSpeechRecognizerListenerScriptProxy registered" );
		if( (IsSupported() == false) && (IsEnabled() == true) )
		{
			SetEnabled( false );
		}
	}
	
	private function OnAudioProblem( audioProblem: int ) : void
	{
		
		
		
		
		
		
		
		LogChannel( 'Kinect', "Audio problem: " + audioProblem );
	}
	
	private function OnRecognizedCommand( recognizedCommand: int, semanticNames : array< string >, semanticValues: array< string >, confidenceScore: float ) : void
	{
	    var i, s : int;     
	    
		if ( theGame )
		{
			if ( theGame.IsDialogOrCutscenePlaying() || IsKinectBlocked() )
			{
				return;
			}
		}
	        
		
		
		
		
		
						      
        
        
		LogChannel( 'Kinect', "Recognized command: " + recognizedCommand );
		LogChannel( 'Kinect', "Recognized command confidence: " + confidenceScore );
				
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
        
		if( confidenceScore > 0.6 )
		{
			switch ( recognizedCommand )
			{
				
				case 0:
					break;

				
				case 1:
					if ( semanticValues[0] == "aard" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Aard' ));
			   else if ( semanticValues[0] == "axii" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Axii' ));
			   else if ( semanticValues[0] == "quen" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Quen' ));
			   else if ( semanticValues[0] == "igni" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Igni' ));
			   else if ( semanticValues[0] == "yrden" ) GetWitcherPlayer().SetEquippedSign(SignStringToEnum( 'Yrden' ));
					break;
		   
				
				case 2:
					break;
					
				
				case 3:
					if ( semanticValues[0] == "map" ) GetWitcherPlayer().GetInputHandler().PushMapScreen();
			   else if ( semanticValues[0] == "quests" ) GetWitcherPlayer().GetInputHandler().PushJournalScreen();
			   else if ( semanticValues[0] == "inventory" ) GetWitcherPlayer().GetInputHandler().PushInventoryScreen();
			   else if ( semanticValues[0] == "character" ) GetWitcherPlayer().GetInputHandler().PushCharacterScreen();
			   else if ( semanticValues[0] == "glossary" ) GetWitcherPlayer().GetInputHandler().PushGlossaryScreen();		   	   
			}
		}
        s = semanticNames.Size();
		for( i=0; i<s; i+=1 )
		{
			LogChannel( 'Kinect', "Name: " + semanticNames[i] + " - Value: " + semanticValues[i] );		
		}
		
	}
	
	private function OnHypothesisAvailable( hypothesis: string ) : void
	{
		LogChannel( 'Kinect', "Hypothesis available: " + hypothesis );		
	}


	private function IsKinectBlocked() : bool
	{
		var result : bool;
		result = false;

		
		if ( theGame.GetGuiManager().IsModalPopupShown() )
		{
			
			result = true;
		}
		
		return result;
	}
}

exec function testVoiceMap()
{
	GetWitcherPlayer().GetInputHandler().PushMapScreen();
}

exec function testVoiceJournal()
{
	GetWitcherPlayer().GetInputHandler().PushJournalScreen();
}

exec function testVoiceInventory()
{
	GetWitcherPlayer().GetInputHandler().PushInventoryScreen();
}

exec function testVoiceCharacter()
{
	GetWitcherPlayer().GetInputHandler().PushCharacterScreen();
}

exec function testVoiceAlchemy()
{
	GetWitcherPlayer().GetInputHandler().PushAlchemyScreen();
}
