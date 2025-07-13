/// @description Draws the Field in the GUI End Event - Also draws the tool-tip

// Inherit the parent event
event_inherited();

//Check mode before drawing componets in this event
if (CTRL_Draw_Event_Used == DRAW_GUI_END)
{Controls_Draw_CommandButton();}

//Display tool-tip
//Place this at the end of each GUI Draw End event in the children of Controls
Control_Display_ToolTip();