/// @description Used when setting the Checkbox's value
//Note: This event can set the checkbox's value even if it is locked.

// Inherit the parent event
event_inherited();

//set CTRL_Text = CTRL_Value
if (bool(CTRL_Value) == true) {CTRL_Text = "true";}
else {CTRL_Value = false; CTRL_Text = "false";}

//Note: checkbox values cycle false -> undefined -> true
//Note: CTRL_Text, which must match CTRL_Value but as a string description, is set in user_event6
switch (CTRL_Value)
{
	case false:
	default:
	{
		CTRL_Value = true;
	}
	break;
	
	//Triple State
	case undefined:
	{
		CTRL_Value = false;
	}
	break;
	
	case true:
	{
		//Triple State
		if (Checkbox_Triple_State)
		{CTRL_Value = undefined;}
		else
		{CTRL_Value = false;}
	}
	break;
}

//"Click" the checkbox in user_event6
event_user(ENUM_Control_User_Events.basic_interaction);