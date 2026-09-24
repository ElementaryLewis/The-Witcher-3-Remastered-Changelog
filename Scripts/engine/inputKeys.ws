/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
function InputKeyToString( keyId : EInputKey ) : string
{
	switch(keyId)
	{
		case IK_Pad_A_CROSS :
			return "enter-gamepad_A";
		case IK_Pad_B_CIRCLE :
			return "escape-gamepad_B";
		case IK_Pad_X_SQUARE :
			return "gamepad_X";
		case IK_Pad_Y_TRIANGLE :
			return "gamepad_Y";
		case IK_Pad_Start :
			return "start";
		case IK_Pad_Back_Select :
		case IK_PS4_OPTIONS :
			return "back";
		case IK_Pad_DigitUp :
			return "dpad_up";
		case IK_Pad_DigitDown :
			return "dpad_down";
		case IK_Pad_DigitLeft :
			return "dpad_left";
		case IK_Pad_DigitRight :
			return "dpad_right";
		case IK_Pad_LeftThumb :	
			return "gamepad_L3";
		case IK_Pad_RightThumb :
			return "gamepad_R3";
		case IK_Pad_LeftShoulder :
			return "gamepad_L1";
		case IK_Pad_RightShoulder :
			return "gamepad_R1";
		case IK_Pad_LeftTrigger :
			return "gamepad_L2";
		case IK_Pad_RightTrigger :
			return "gamepad_R2";
	}
	return "";
}