/// @description Unicode Character Database lookups and legacy string functions.
/// @see https://www.unicode.org/reports/tr44/

#region Raw table columns

/// @description The public 18-column CSV layout. The middle 15 fields follow UnicodeData.txt.
enum enum_Unicode
{
    custom_HEX_8,
    custom_ord_1,
    Code_Point,
    Name,
    General_Category,
    Canonical_Combining_Class,
    Bidi_Class,
    Decomposition_Mapping,
    Decimal_Digit_Value,
    Digit_Value,
    Numeric_Value,
    Mirrored,
    Unicode_Name_Index, // Unicode 1.0 name.
    Reserved, // ISO 10646 comment column, reserved in the UCD.
    Uppercase_Mapping,
    Lowercase_Mapping,
    Titlecase_Mapping,
    custom_ord_2,
    length = 18
}

#endregion

#region Get macros for the Unicode general categories
#macro Unicode_General_Category_Control					"Cc"
#macro Unicode_General_Category_Format					"Cf"
#macro Unicode_General_Category_Private_Use				"Co"
#macro Unicode_General_Category_Surrrogate				"Cs"
#macro Unicode_General_Category_Lowercase_Letter		"Ll"
#macro Unicode_General_Category_Modifier_Letter			"Lm"
#macro Unicode_General_Category_Other_Letter			"Lo"
#macro Unicode_General_Category_Titlecase_Letter		"Lt"
#macro Unicode_General_Category_Uppercase_Letter		"Lu"
#macro Unicode_General_Category_Spacing_Mark			"Mc"
#macro Unicode_General_Category_Enclosing_Mark			"Me"
#macro Unicode_General_Category_Nonspacing_Mark			"Mn"
#macro Unicode_General_Category_Decimal_Number			"Nd"
#macro Unicode_General_Category_Letter_Number			"Nl"
#macro Unicode_General_Category_Other_Number			"No"
#macro Unicode_General_Category_Connector_Punctuation	"Pc"
#macro Unicode_General_Category_Dash_Punctuation		"Pd"
#macro Unicode_General_Category_Close_Punctuation		"Pe"
#macro Unicode_General_Category_Final_Punctuation		"Pf"
#macro Unicode_General_Category_Initial_Punctuation		"Pi"
#macro Unicode_General_Category_Other_Punctuation		"Po"
#macro Unicode_General_Category_Open_Punctuation		"Ps"
#macro Unicode_General_Category_Currency_Symbol			"Sc"
#macro Unicode_General_Category_Modifier_Symbol			"Sk"
#macro Unicode_General_Category_Math_Symbol				"Sm"
#macro Unicode_General_Category_Other_Symbol			"So"
#macro Unicode_General_Category_Line_Separator			"Zl"
#macro Unicode_General_Category_Paragraph_Separator		"Zp"
#macro Unicode_General_Category_Space_Separator			"Zs"
#endregion

#region Optional raw lookup tables

// Included Files contains one complete table per Unicode plane and a compact map source.
#macro UNICODE_PLANE_COUNT 17
#macro UNICODE_PLANE_HEIGHT 65536
#macro UNICODE_PLANE_FILE_PATH "Unicode/Planes/"
#macro UNICODE_PLANES_ALL [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
#macro UNICODE_GRID_EMPTY_CELL_DEFAULT undefined

#macro UNICODE_DATA_CSV_FILE_PATH "Unicode/"
#macro UNICODE_DATA_CSV_FILE_NAME "UnicodeData.csv"
#macro UNICODE_LOOKUP_MODE_GRID 0
#macro UNICODE_LOOKUP_MODE_MAP 1

global.grid_Unicode_CSV = -1;
global.map_Unicode_CSV = -1;
global.Unicode_lookup_mode = UNICODE_LOOKUP_MODE_MAP;

/// @ignore Allocate the legacy data structures only for explicit raw-table callers.
function Unicode_prepare_legacy_tables()
{
    if (global.grid_Unicode_CSV == -1) global.grid_Unicode_CSV = ds_grid_create(enum_Unicode.length, 1);
    if (global.map_Unicode_CSV == -1) global.map_Unicode_CSV = ds_map_create();
}

/// @description Release both optional raw Unicode tables. Subsequent explicit initialization recreates them.
function Unicode_release_tables()
{
    if (global.grid_Unicode_CSV != -1) ds_grid_destroy(global.grid_Unicode_CSV);
    if (global.map_Unicode_CSV != -1) ds_map_destroy(global.map_Unicode_CSV);
    global.grid_Unicode_CSV = -1;
    global.map_Unicode_CSV = -1;
}

/// @ignore Load and validate the shape of one bundled raw lookup table.
function Unicode_load_legacy_csv(_path, _rows = undefined)
{
    if (!file_exists(_path)) throw "Missing Unicode lookup table: " + _path;
    var table = load_csv(_path);
    if (!ds_exists(table, ds_type_grid)) throw "Cannot read Unicode lookup table: " + _path;
    var row_count = ds_grid_height(table);
    if (ds_grid_width(table) != enum_Unicode.length || row_count == 0
        || (!is_undefined(_rows) && row_count != _rows))
    {
        ds_grid_destroy(table);
        throw "Invalid Unicode lookup table dimensions: " + _path;
    }
    return table;
}

/// @ignore Validate the entire request before opening any files or changing active tables.
function Unicode_validate_planes(_planes)
{
    if (!is_array(_planes)) throw "Unicode planes must be an array.";
    var selected = array_create(UNICODE_PLANE_COUNT, false);
    for (var i = 0; i < array_length(_planes); ++i)
    {
        var plane = _planes[i];
        if (!is_real(plane) || plane != floor(plane) || plane < 0 || plane >= UNICODE_PLANE_COUNT)
            throw "Unicode plane must be an integer from 0 through 16.";
        selected[plane] = true;
    }
    return selected;
}

/// @ignore Locate the bundled CSV for a validated plane number.
function Unicode_plane_path(_plane)
{
    return UNICODE_PLANE_FILE_PATH + "Unicode Plane " + string(_plane) + ".csv";
}

/// @description Load selected bundled Unicode planes into a raw table indexed by code point.
/// @param {Array<Real>} [_planes] Planes 0 through 16. Unloaded rows retain their code point columns.
/// @returns {Undefined}
function Unicode_set_grid_to_be_full_Unicode_table_and_use_grid_mode(_planes = UNICODE_PLANES_ALL)
{
    var selected = Unicode_validate_planes(_planes);
    var next = ds_grid_create(enum_Unicode.length, UNICODE_PLANE_COUNT * UNICODE_PLANE_HEIGHT);
    try
    {
        ds_grid_clear(next, UNICODE_GRID_EMPTY_CELL_DEFAULT);
        for (var plane = 0; plane < UNICODE_PLANE_COUNT; ++plane)
        {
            var first = plane * UNICODE_PLANE_HEIGHT;
            if (selected[plane])
            {
                var table = Unicode_load_legacy_csv(Unicode_plane_path(plane), UNICODE_PLANE_HEIGHT);
                try { ds_grid_set_grid_region(next, table, 0, 0, enum_Unicode.length - 1, UNICODE_PLANE_HEIGHT - 1, 0, first); }
                finally { ds_grid_destroy(table); }
            }
            else
            {
                for (var scalar = first; scalar < first + UNICODE_PLANE_HEIGHT; ++scalar)
                {
                    next[# enum_Unicode.custom_HEX_8, scalar] = convert_ord_to_at_least_8_digit_hex(scalar);
                    next[# enum_Unicode.custom_ord_1, scalar] = string(scalar);
                    next[# enum_Unicode.custom_ord_2, scalar] = string(scalar);
                }
            }
        }
    }
    catch (problem) { ds_grid_destroy(next); throw problem; }
    Unicode_release_tables();
    global.grid_Unicode_CSV = next;
    global.Unicode_lookup_mode = UNICODE_LOOKUP_MODE_GRID;
}

/// @ignore Copy one verified CSV into the next map and free its temporary grid.
function Unicode_append_map_csv(_map, _path, _plane = false)
{
    var table = Unicode_load_legacy_csv(_path, _plane ? UNICODE_PLANE_HEIGHT : undefined);
    try
    {
        var row_count = ds_grid_height(table);
        for (var slot = 0; slot < row_count; ++slot)
        {
            if (_plane && table[# enum_Unicode.General_Category, slot] == "Cn") continue;
            var record = array_create(enum_Unicode.length);
            for (var field = 0; field < enum_Unicode.length; ++field)
                record[field] = table[# field, slot];
            ds_map_add(_map, real(record[enum_Unicode.custom_ord_1]), record);
        }
    }
    finally { ds_grid_destroy(table); }
}

/// @description Cache the assigned code points in all or selected Unicode planes.
/// @param {Array<Real>} [_planes] Plane numbers 0 through 16. An empty array creates an empty map.
/// @returns {Undefined}
function Unicode_set_map_to_be_UnicodeData_table_and_use_map_mode(_planes = UNICODE_PLANES_ALL)
{
    var selected = Unicode_validate_planes(_planes);
    var next = ds_map_create();
    try
    {
        if (!array_contains(selected, false))
            Unicode_append_map_csv(next, UNICODE_DATA_CSV_FILE_PATH + UNICODE_DATA_CSV_FILE_NAME);
        else
            for (var plane = 0; plane < UNICODE_PLANE_COUNT; ++plane)
                if (selected[plane]) Unicode_append_map_csv(next, Unicode_plane_path(plane), true);
    }
    catch (problem) { ds_map_destroy(next); throw problem; }
    Unicode_release_tables();
    global.map_Unicode_CSV = next;
    global.Unicode_lookup_mode = UNICODE_LOOKUP_MODE_MAP;
}

/// @param {Real} _mode UNICODE_LOOKUP_MODE_GRID or UNICODE_LOOKUP_MODE_MAP.
/// @param {Array<Real>} [_planes] Planes to include in either mode.
/// @returns {Undefined}
function Unicode_set_mode(_mode, _planes = UNICODE_PLANES_ALL)
{
    if (_mode == UNICODE_LOOKUP_MODE_GRID)
        Unicode_set_grid_to_be_full_Unicode_table_and_use_grid_mode(_planes);
    else
    {
        if (_mode != UNICODE_LOOKUP_MODE_MAP) show_debug_message("Unknown Unicode lookup mode. Using map mode.");
        Unicode_set_map_to_be_UnicodeData_table_and_use_map_mode(_planes);
    }
}


#endregion

#region Unicode plane cache

/// @description An independent cache for raw Unicode metadata from selected plane CSVs.
/// @param {Array<Real>} [_planes] Initial plane numbers from 0 through 16. Defaults to empty.
/// @returns {Struct.Unicode_plane_cache} A cache that owns its tables until unloaded or cleaned up.
function Unicode_plane_cache(_planes = []) constructor
{
    #region Instance state

    plane_maps = array_create(UNICODE_PLANE_COUNT, -1);
    disposed = false;

    #endregion

    #region Getters and setters

    /// @returns {Array<Real>} Loaded plane numbers in ascending order.
    static get_planes = function()
    {
        var loaded = [];
        for (var plane = 0; plane < UNICODE_PLANE_COUNT; ++plane)
            if (plane_maps[plane] != -1) array_push(loaded, plane);
        return loaded;
    };

    /// @param {Real} _point Code point to look up.
    /// @returns {Array|Undefined} A copy of the 18-column record, or undefined if not cached or unassigned.
    static get = function(_point)
    {
        if (!is_real(_point) || _point != floor(_point) || _point < 0 || _point > $10FFFF) return undefined;
        var table = plane_maps[_point div UNICODE_PLANE_HEIGHT];
        if (table == -1 || !ds_map_exists(table, _point)) return undefined;
        return variable_clone(table[? _point]);
    };

    /// @description Replace the loaded set. A failed read preserves the previous set.
    /// @param {Array<Real>} _planes Plane numbers from 0 through 16.
    /// @returns {Struct.Unicode_plane_cache} This cache.
    static set_planes = function(_planes)
    {
        if (disposed) throw "Cannot configure a disposed Unicode plane cache.";
        var selected = Unicode_validate_planes(_planes);
        var next = array_create(UNICODE_PLANE_COUNT, -1);
        try
        {
            for (var plane = 0; plane < UNICODE_PLANE_COUNT; ++plane)
            {
                if (!selected[plane]) continue;
                next[plane] = plane_maps[plane];
                if (next[plane] != -1) continue;
                next[plane] = ds_map_create();
                Unicode_append_map_csv(next[plane], Unicode_plane_path(plane), true);
            }
        }
        catch (problem)
        {
            for (var plane = 0; plane < UNICODE_PLANE_COUNT; ++plane)
                if (next[plane] != -1 && next[plane] != plane_maps[plane]) ds_map_destroy(next[plane]);
            throw problem;
        }
        for (var plane = 0; plane < UNICODE_PLANE_COUNT; ++plane)
            if (!selected[plane] && plane_maps[plane] != -1) ds_map_destroy(plane_maps[plane]);
        plane_maps = next;
        return self;
    };

    #endregion

    #region Methods

    /// @param {Real} _plane Plane number from 0 through 16.
    /// @returns {Struct.Unicode_plane_cache} This cache. A loaded plane is reused.
    static load = function(_plane)
    {
        return set_planes(array_concat(get_planes(), [_plane]));
    };

    /// @param {Real} _plane Plane number from 0 through 16.
    /// @returns {Struct.Unicode_plane_cache} This cache.
    static unload = function(_plane)
    {
        Unicode_validate_planes([_plane]);
        var loaded = get_planes(), slot = array_get_index(loaded, _plane);
        if (slot >= 0) array_delete(loaded, slot, 1);
        return set_planes(loaded);
    };

    /// @description Release every owned table. Calling this twice is safe.
    static clean_up = function()
    {
        if (disposed) return;
        set_planes([]);
        disposed = true;
    };

    #endregion

    #region Initialization

    set_planes(_planes);

    #endregion
}

#endregion

#region Legacy category groups
//Letters
global.arr_Unicode_letter_cased = [Unicode_General_Category_Uppercase_Letter,
								   Unicode_General_Category_Lowercase_Letter,
								   Unicode_General_Category_Titlecase_Letter];
									
global.arr_Unicode_letter_other = [Unicode_General_Category_Modifier_Letter,
								   Unicode_General_Category_Other_Letter];
								   
global.arr_Unicode_letter_all = [Unicode_General_Category_Uppercase_Letter,
								 Unicode_General_Category_Lowercase_Letter,
								 Unicode_General_Category_Titlecase_Letter,
								 Unicode_General_Category_Modifier_Letter,
								 Unicode_General_Category_Other_Letter];

//Marks
global.arr_Unicode_marks = [Unicode_General_Category_Spacing_Mark,
							Unicode_General_Category_Enclosing_Mark,
							Unicode_General_Category_Nonspacing_Mark];

//Digits (or chars akin to digits)
global.arr_Unicode_number_decimal_digit = [Unicode_General_Category_Decimal_Number]; //Recommended for most use-cases involving filtering numeric digits
global.arr_Unicode_number_letter_number = [Unicode_General_Category_Letter_Number]; //I.E. A Roman numeral
global.arr_Unicode_number_other = [Unicode_General_Category_Other_Number];

global.arr_Unicode_number_all = [Unicode_General_Category_Decimal_Number,
								 Unicode_General_Category_Letter_Number,
								 Unicode_General_Category_Other_Number];

//Letters and digits
global.arr_Unicode_lettersdigits = [Unicode_General_Category_Uppercase_Letter,
									Unicode_General_Category_Lowercase_Letter,
									Unicode_General_Category_Titlecase_Letter,
									Unicode_General_Category_Other_Letter,
									Unicode_General_Category_Modifier_Letter,
									Unicode_General_Category_Spacing_Mark,
									Unicode_General_Category_Enclosing_Mark,
									Unicode_General_Category_Nonspacing_Mark,
									Unicode_General_Category_Decimal_Number]; //Used with string_lettersdigits2()

//letters
global.arr_Unicode_letters = [Unicode_General_Category_Uppercase_Letter,
							  Unicode_General_Category_Lowercase_Letter,
							  Unicode_General_Category_Titlecase_Letter,
							  Unicode_General_Category_Other_Letter,
							  Unicode_General_Category_Spacing_Mark,
							  Unicode_General_Category_Enclosing_Mark,
							  Unicode_General_Category_Nonspacing_Mark,
							  Unicode_General_Category_Modifier_Letter]; //Used with string_letters2()

//Punctuation
global.arr_Unicode_punctuation = [Unicode_General_Category_Connector_Punctuation,	
								  Unicode_General_Category_Dash_Punctuation,		
								  Unicode_General_Category_Close_Punctuation,		
								  Unicode_General_Category_Final_Punctuation,		
								  Unicode_General_Category_Initial_Punctuation,	
								  Unicode_General_Category_Other_Punctuation,		
								  Unicode_General_Category_Open_Punctuation]; //Used with string_punctuation()



//Symbols
global.arr_Unicode_symbols = [Unicode_General_Category_Currency_Symbol,	
							  Unicode_General_Category_Modifier_Symbol,	
							  Unicode_General_Category_Math_Symbol,			
							  Unicode_General_Category_Other_Symbol];
							 
// Punctuation and symbols					 
global.arr_Unicode_punctuationsymbols = [Unicode_General_Category_Connector_Punctuation,
										 Unicode_General_Category_Dash_Punctuation,	
										 Unicode_General_Category_Close_Punctuation,	
										 Unicode_General_Category_Final_Punctuation,	
										 Unicode_General_Category_Initial_Punctuation,	
										 Unicode_General_Category_Other_Punctuation,	
										 Unicode_General_Category_Open_Punctuation,
										 Unicode_General_Category_Currency_Symbol,	
										 Unicode_General_Category_Modifier_Symbol,	
										 Unicode_General_Category_Math_Symbol,			
										 Unicode_General_Category_Other_Symbol]; //Used with string_punctuationsymbols()
							 
//Control
global.arr_Unicode_control = [Unicode_General_Category_Control,
							  Unicode_General_Category_Format,	
							  Unicode_General_Category_Private_Use,
							  Unicode_General_Category_Surrrogate]; //Used with string_control()

//Whitespace
global.arr_Unicode_whitespace =	[Unicode_General_Category_Line_Separator,
								 Unicode_General_Category_Paragraph_Separator,	
								 Unicode_General_Category_Space_Separator]; //Used with string_whitespace()
// White_Space includes these Cc characters in addition to the separator categories.
global.arr_Unicode_whitespace_extra_ords = [9, 10, 11, 12, 13, 133];

#endregion

#region string functions that work with the Unicode general categories

/// @description Letters, combining marks and decimal digits.
/// @param {String} _str Source string.
/// @param {Bool} [_true_if_char_in_unassigned_Unicode_plane] Include unassigned code points.
/// @returns {String} Matching characters in source order.
function string_lettersdigits2(_str, _true_if_char_in_unassigned_Unicode_plane = true)
{
    static reader = new Unicode_text();
    return reader.filter_categories(_str, ["L", "M", "Nd"], _true_if_char_in_unassigned_Unicode_plane);
}

/// @description Letters and combining marks.
/// @param {String} _str Source string.
/// @param {Bool} [_true_if_char_in_unassigned_Unicode_plane] Include unassigned code points.
/// @returns {String} Matching characters in source order.
function string_letters2(_str, _true_if_char_in_unassigned_Unicode_plane = true)
{
    static reader = new Unicode_text();
    return reader.filter_categories(_str, ["L", "M"], _true_if_char_in_unassigned_Unicode_plane);
}

/// @description Decimal digits from all scripts.
/// @param {String} _str Source string.
/// @returns {String} Matching characters in source order.
function string_digits2(_str)
{
    static reader = new Unicode_text();
    return reader.filter_categories(_str, ["Nd"]);
}

/// @description Unicode punctuation.
/// @param {String} _str Source string.
/// @returns {String} Matching characters in source order.
function string_punctuation(_str)
{
    static reader = new Unicode_text();
    return reader.filter_categories(_str, ["P"]);
}

/// @description Unicode symbols.
/// @param {String} _str Source string.
/// @returns {String} Matching characters in source order.
function string_symbols(_str)
{
    static reader = new Unicode_text();
    return reader.filter_categories(_str, ["S"]);
}

/// @description Unicode punctuation and symbols.
/// @param {String} _str Source string.
/// @returns {String} Matching characters in source order.
function string_punctuationsymbols(_str)
{
    static reader = new Unicode_text();
    return reader.filter_categories(_str, ["P", "S"]);
}

/// @description Control, format, private-use and surrogate categories.
/// @param {String} _str Source string.
/// @returns {String} Matching characters in source order.
function string_control(_str)
{
    static reader = new Unicode_text();
    return reader.filter_categories(_str, ["Cc", "Cf", "Co", "Cs"]);
}

/// @param {String} _str Source text.
/// @returns {String} Characters with the Unicode White_Space property.
function string_whitespace(_str)
{
    static reader = new Unicode_text();
    return reader.whitespace(_str);
}

/// @param {String} _str Source text.
/// @returns {String} Unicode uppercase text.
function string_upper2(_str)
{
    static reader = new Unicode_text();
    return reader.change_case(_str, "upper");
}

/// @param {String} _str Source text.
/// @returns {String} Unicode lowercase text.
function string_lower2(_str)
{
    static reader = new Unicode_text();
    return reader.change_case(_str, "lower");
}

/// @param {String} _str Source text.
/// @returns {String} Unicode titlecase text.
function string_title(_str)
{
    static reader = new Unicode_text();
    return reader.change_case(_str, "title");
}

/// @function Unicode_lookup_check_mode
/// @descirption Checks whether the mode is correct and that the proper data-structure is used.
/// @param {real}	mode	The Unicode mode (UNICODE_LOOKUP_MODE_GRID or UNICODE_LOOKUP_MODE_MAP) Other values will return an error
/// @param {object}	func	The function being checked
/// @returns {void}
/// @author The Games Re-creation Project
/// @license GNU
/// @description Report a missing optional table to the calling legacy script.
/// @param {Real} _mode Raw lookup mode.
/// @param {Function} _func Caller to identify in the diagnostic.
function Unicode_lookup_check_mode(_mode, _func)
{
    switch (_mode)
    {
        case UNICODE_LOOKUP_MODE_GRID:
            if (!ds_exists(global.grid_Unicode_CSV, ds_type_grid))
                show_error(string("{0} requires the Unicode grid. Initialize it with Unicode_set_mode().", nameof(_func)), false);
            break;
        case UNICODE_LOOKUP_MODE_MAP:
            if (!ds_exists(global.map_Unicode_CSV, ds_type_map))
                show_error(string("{0} requires the Unicode map. Initialize it with Unicode_set_mode().", nameof(_func)), false);
            break;
        default: show_error("Unknown Unicode table mode.", false);
    }
}

/// @description Convert a code point with the original Unicode helper's validity rules.
/// @param {Real} _ord Unicode code point.
/// @returns {String} The character, or an empty string for an out-of-range value, surrogate or U+10FFFF.
function chr_Unicode(_ord)
{
    if (_ord < 0 || _ord >= $10FFFF || (_ord >= $D800 && _ord <= $DFFF)) return "";
    return chr(_ord);
}

/// @description Read a character at a GameMaker string position. Combine a UTF-16 surrogate pair if present.
/// @param {String} _str Source string.
/// @param {Real} _pos One-based string position.
/// @returns {String} The character, U+FFFD for an isolated surrogate, or an empty string outside the source.
function string_char_at_get_as_usable_Unicode_surrogate(_str, _pos)
{
    var count = string_length(_str);
    if (_pos < 1 || _pos > count) return "";
    var character = string_char_at(_str, _pos);
    if (character == "") return "";

    var scalar = ord(character);
    if (scalar < $D800 || scalar > $DFFF) return character;
    if (scalar > $DBFF || _pos >= count) return "�";

    var trailing = string_char_at(_str, _pos + 1);
    if (trailing == "") return "�";
    var low = ord(trailing);
    if (low < $DC00 || low > $DFFF) return "�";
    return chr((scalar - $D800) * $400 + low - $DC00 + $10000);
}

/// @param {Real} _ord Unicode code point from U+0000 through U+10FFFF.
/// @returns {String} Uppercase hexadecimal code point padded to at least four digits.
function get_hex_from_ord(_ord)
{
    return unicode_ordinal_hex(_ord, 4);
}

/// @param {Real} _ord Unicode code point.
/// @returns {String} Uppercase hexadecimal code point padded to at least four digits.
function convert_ord_to_at_least_4_digit_hex(_ord)
{
    return unicode_ordinal_hex(_ord, 4);
}

/// @param {Real} _ord Unicode code point.
/// @returns {String} Eight-digit uppercase hexadecimal code point.
function convert_ord_to_at_least_8_digit_hex(_ord)
{
    return unicode_ordinal_hex(_ord, 8);
}

/// @ignore Convert an integer without casting it to a platform pointer.
function unicode_ordinal_hex(_ord, _minimum_width)
{
    if (!is_real(_ord) || _ord != floor(_ord) || _ord < 0 || _ord > $10FFFF) return "";
    var result = "";
    var remaining = _ord;
    repeat (_minimum_width)
    {
        result = string_char_at("0123456789ABCDEF", (remaining & 15) + 1) + result;
        remaining = remaining >> 4;
    }
    while (remaining > 0)
    {
        result = string_char_at("0123456789ABCDEF", (remaining & 15) + 1) + result;
        remaining = remaining >> 4;
    }
    return result;
}

/// @description Apply the Unicode mapping identified by a legacy table column.
/// @param {String} _str Source string.
/// @param {Real} _mapping_type Uppercase_Mapping, Lowercase_Mapping or Titlecase_Mapping.
/// @returns {String} Full Unicode case mapping.
function Unicode_get_upper_lower_title_case_mapped_chr(_str, _mapping_type)
{
    switch (_mapping_type)
    {
        case enum_Unicode.Uppercase_Mapping: return string_upper2(_str);
        case enum_Unicode.Lowercase_Mapping: return string_lower2(_str);
        case enum_Unicode.Titlecase_Mapping: return string_title(_str);
        default: throw "Expected a Unicode case mapping column.";
    }
}

#endregion
