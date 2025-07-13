/// @description Resizes the Checkbox's caption under a specific circumstance
// If auto-size used and the final control is instantiated at room create event, or new control is fully instantiated

// Inherit the parent event
event_inherited();

//If the caption must be reset, re-run any bounds and vertex functions
//circumstances for a Radio Button
if (caption_string_auto_caption_reset)
{
	var updated_caption = struct_checkBox.caption_string;
	//build the radio button
	Checkbox_Design(struct_checkBox, updated_caption);
	//Set bounds
	control_bounds_xx1 = struct_checkBox.xx1;
	control_bounds_yy1 = struct_checkBox.yy1;
	control_bounds_xx2 = struct_checkBox.xx2;
	control_bounds_yy2 = struct_checkBox.yy2;
	
	caption_string_auto_caption_reset = false;
}