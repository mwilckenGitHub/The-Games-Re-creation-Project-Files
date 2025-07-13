/// @description Draws the Command Button in the Normal Draw Event

// Inherit the parent event
event_inherited();

//Check mode before drawing componets in this event
if (CTRL_Draw_Event_Used == DRAW_NORMAL_END && !control_drawn_to_surface)
{Controls_Draw_CommandButton();}