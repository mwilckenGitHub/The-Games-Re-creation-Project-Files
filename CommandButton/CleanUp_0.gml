/// @description Cleans the CommandButton up

// Inherit the parent event
event_inherited();

clean_up_CommandButton(id);

if (is_struct(struct_commandButton)) {delete struct_commandButton;}