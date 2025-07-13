/// @description Draws the Checkbox in the GUI End Event - Also draws the tool-top

// Inherit the parent event
event_inherited();

//Check mode before drawing componets in this event
if (CTRL_Draw_Event_Used == DRAW_GUI_END && !control_drawn_to_surface)
{Controls_Draw_Checkbox();}

//Display tool-tip
//Place this at the end of each GUI Draw End event in the children of Controls
Control_Display_ToolTip();