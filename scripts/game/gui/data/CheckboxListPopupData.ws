/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct W3CheckboxData
{
	var label : string; default label = "undefined";
	var checked : bool; default checked = false;
}

class W3CheckboxListPopupData extends ConfirmationPopupData
{
	public var m_textSecondary : string;
	public var m_checkboxes : array< W3CheckboxData >;
	
	public function SetTextSecondary( text:string )
	{
		m_textSecondary = text;
	}
	
    public function AddCheckBoxText( text : string, optional checked : bool ) : void
	{
        var checkbox : W3CheckboxData;
        checkbox.label = text;
        checkbox.checked = checked;
		m_checkboxes.PushBack(checkbox);
	}

	public function OnCheckboxValueChanged( index:int, value:bool )
	{
		m_checkboxes[ index ].checked = value;
	}

	protected  function GetContentRef() : string 
	{
		return "CheckboxListPopupRef";
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		LogChannel( 'GFX ', "OnUserFeedback " + KeyCode );

        
        
        
		if ( KeyCode == "enter-gamepad_A" )
		{								   
			OnUserAccept();				   
		}
		else if ( KeyCode == "escape-gamepad_B" ) 
		{
			OnUserDecline();
		}
	}
	
	public  function GetGFxData( parentFlashValueStorage : CScriptedFlashValueStorage ) : CScriptedFlashObject
	{
		var l_flashObject : CScriptedFlashObject;
		var l_flashTempObject : CScriptedFlashObject;
		var l_flashTempArray : CScriptedFlashArray;
		var i : int = 0;
		
		l_flashObject = parentFlashValueStorage.CreateTempFlashObject();
		l_flashObject.SetMemberFlashString( "ContentRef", GetContentRef() );
		l_flashObject.SetMemberFlashString( "TextContent", m_TextContent );
		l_flashObject.SetMemberFlashString( "TextTitle", m_TextTitle );
		l_flashObject.SetMemberFlashString( "TextSecondary", m_textSecondary );
		l_flashObject.SetMemberFlashString( "ImagePath", m_ImagePath );
		
		l_flashTempArray = parentFlashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < m_checkboxes.Size(); i+= 1 )
		{
			l_flashTempObject = parentFlashValueStorage.CreateTempFlashObject();
			l_flashTempObject.SetMemberFlashString( "label", m_checkboxes[i].label );
			l_flashTempObject.SetMemberFlashBool( "checked", m_checkboxes[i].checked );
			l_flashTempArray.PushBackFlashObject( l_flashTempObject );
		}
		l_flashObject.SetMemberFlashArray( "CheckBoxes", l_flashTempArray );
		
		l_flashObject.SetMemberFlashBool( "backgroundVisible", m_DisplayGreyBackground );
		
		return l_flashObject;
	}
	
	protected  function OnUserAccept() : void
	{
		ClosePopup();
	}
	
	protected  function OnUserDecline() : void
	{
		ClosePopup();
	}
	
	protected  function GetAcceptText() : string
	{
		return "panel_button_common_accept";
	}
	
	protected  function GetDeclineText() : string
	{
		return "panel_button_common_exit";
	}
	
	protected  function DefineDefaultButtons():void
	{
		var checkboxEnablePadNavCode : string = "gamepad_X";

		if (theGame.GetPlatform() == Platform_Switch2_Ounce)
		{
			checkboxEnablePadNavCode = "gamepad_Y";
		}

		AddButtonDef( "panel_button_common_accept", "enter-gamepad_A", IK_Enter );
		AddButtonDef( "panel_button_common_exit", "escape-gamepad_B", IK_Escape );
		AddButtonDef( "panel_checkbox_default_enable", checkboxEnablePadNavCode, IK_Space );
	}
	
}