/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct W3UrlButtonData
{
	var label : string; default label = "undefined";
	var urlLink : ETermsLinkType;
}

class W3UrlCheckboxListPopupData extends W3CheckboxListPopupData
{
	public var m_urls : array< W3UrlButtonData >;
	
    public function AddUrlLink( text : string, link : ETermsLinkType ) : void
	{
        var url : W3UrlButtonData;
        url.label = text;
        url.urlLink = link;
		m_urls.PushBack(url);
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
		
		l_flashTempArray = parentFlashValueStorage.CreateTempFlashArray();
		
		for( i = 0; i < m_urls.Size(); i+= 1 )
		{
			l_flashTempObject = parentFlashValueStorage.CreateTempFlashObject();
			l_flashTempObject.SetMemberFlashString( "label", m_urls[i].label );
			l_flashTempObject.SetMemberFlashInt( "link", m_urls[i].urlLink );
			l_flashTempArray.PushBackFlashObject( l_flashTempObject );
		}
		l_flashObject.SetMemberFlashArray( "URLButtons", l_flashTempArray );
		
		l_flashObject.SetMemberFlashBool( "backgroundVisible", m_DisplayGreyBackground );
		
		return l_flashObject;
	}
}