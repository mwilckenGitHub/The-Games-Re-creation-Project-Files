/// @description Resizes the CommandButton's caption under a specific circumstance
// If auto-size used and the final control is instantiated at room create event, or new control is fully instantiated

// Inherit the parent event
event_inherited();

//If the caption must be reset, re-run any bounds and vertex functions
//circumstances for a Command Button
if (caption_string_auto_caption_reset)
{
	var updated_caption = struct_commandButton.caption_string;
	//build the command button
	CommandButton_Design(struct_commandButton, updated_caption);
	//Set bounds
	control_bounds_xx1 = struct_commandButton.xx1;
	control_bounds_yy1 = struct_commandButton.yy1;
	control_bounds_xx2 = struct_commandButton.xx2;
	control_bounds_yy2 = struct_commandButton.yy2;
	
	caption_string_auto_caption_reset = false;
}