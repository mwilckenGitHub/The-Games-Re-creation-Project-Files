/// @description Resizes the Decorative Button's caption under a specific circumstance
// If auto-size used and the final control is instantiated at room create event, or new control is fully instantiated

// Inherit the parent event
event_inherited();

//If the caption must be reset, re-run any bounds and vertex functions
//circumstances for a Decorative Button
if (caption_string_auto_caption_reset)
{
	var updated_caption = struct_decorativeButton.caption_string;
	//build the decorative button using command button design
	CommandButton_Design(struct_decorativeButton, updated_caption);
	//Set bounds
	control_bounds_xx1 = struct_decorativeButton.xx1;
	control_bounds_yy1 = struct_decorativeButton.yy1;
	control_bounds_xx2 = struct_decorativeButton.xx2;
	control_bounds_yy2 = struct_decorativeButton.yy2;
	
	caption_string_auto_caption_reset = false;
}