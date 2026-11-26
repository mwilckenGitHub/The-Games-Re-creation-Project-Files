/// @description Unicode string helpers and optional raw Unicode Character Database tables.
/// @see {https://www.unicode.org/reports/tr44/#Property_Values}
/**
* After much consideration we have decided to use the grid/map method wherein the ds_grid is initially populated by the CSV which then populates the ds_map
* Though this method yeilds a slighly slower result at run-time, it loads much faster at startup and makes it easier to simply use the standard UnicodeData.txt
* rather than loading so many Unicode planes, many of which are unassigned characters. We have built in checks in our new string_...2() functions to check for
* whether a character is undefined when returned from the map (indicitve of an unloaded plane).
*/


//UnicodeData.txt Index Column Name Description
//Note: These are the default columns in the UnicodeData.txt. The enum_Unicode contains extra, custom coluns which were used in Excel to make acquiring the Unicode Data easier
//0		Code Point					Hexadecimal Unicode code point (e.g., $0025)
//1		Name						Character name
//2		General Category			Unicode category (e.g., Po, Cc, etc.)
//3		Canonical Combining Class	Integer for combining class (usually 0 for non-combining)
//4		Bidi Class					Bidirectional text class (e.g., L, R, BN, etc.)
//5		Decomposition Mapping		If applicable, decomposition (compatibility/canonical)
//6		Decimal Digit Value			Only valid for decimal digits (e.g., 0–9)
//7		Digit Value					Similar to Decimal but includes additional digit-like characters
//8		Numeric Value				Broader numeric meaning (e.g., fractions, Roman numerals, etc.)
//9		Mirrored					Boolean indicating if character has a mirrored glyph in RTL contexts
//10	Unicode Name Index			Seems to be a lookup or string index — or may be a redundant field here
//11	Reserved					Reserved
//12	Uppercase Mapping			Uppercase Mapping
//13	Lowercase Mapping			Lowercase Mapping
//14	Titlecase Mapping			Titlecase Mapping

enum enum_Unicode {
	custom_HEX_8,				//A custom column used to make acquiring the Unicode output from Excel easier. This column is preseved in the .csv for future proofing
	custom_ord_1,				//Note: This is the only column that returns as a real in ds_map mode! A custom column used to make acquiring the Unicode output from Excel easier. This column is preseved in the .csv for future proofing
	Code_Point,					//The default hex value from UnicodeData.txt ///@see {https://www.unicode.org/Public/reconstructed/1.0.1/UnicodeData.txt}
	Name,						//The default name of this character		
	General_Category,			//The general category which determines what type of character is being referenced	
	Canonical_Combining_Class,	//How this character combines with others (advanced - unused by this script as of 6/21/2025)
	Bidi_Class,					//the Bi-directional class (advanced - unused by this script as of 6/21/2025)
	Decomposition_Mapping,		//How this character is constructed (advanced - unused by this script as of 6/21/2025)
	Decimal_Digit_Value,		//The numerical value of this character
	Digit_Value,				//The numerical value of this character
	Numeric_Value,				//The numerical value of this character
	Mirrored,					//Whether this character is mirrored (default values are "Y"/"N")
	Unicode_Name_Index,			//The name of this character in English only
	Reserved,					//Unused
	Uppercase_Mapping,			//What other character this character maps to for case changes
	Lowercase_Mapping,			//What other character this character maps to for case changes
	Titlecase_Mapping,			//What other character this character maps to for case changes
	custom_ord_2,				//A custom column used to make acquiring the Unicode output from Excel easier. This column is preseved in the .csv for future proofing
	length = 18					//The total width of the Unicode tables in the input csv Unicode plane files
}

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

//Get included files directory

//Planes
//Advanced users only
//Your files should be located in the working_directory under "Unicode/Planes/Unicode Plane 0.csv"
//Note: Files are numbered from 0 - 16
#macro UNICODE_PLANE_COUNT 17 //the total number of Unicode planes in the database as of Version 16.0.0. These planes correspond to the Unicode Plane files in the included files.
#macro UNICODE_PLANE_HEIGHT 65536 //Each plane is 2^16
#macro UNICODE_PLANE_FILE_PATH "Unicode/Planes/"
//User: You may remove from this array the planes you do not wish to load. Note that Unicode has 17 planes
#macro UNICODE_PLANES_ALL [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
#macro UNICODE_GRID_EMPTY_CELL_DEFAULT undefined

//Basic
//Recommended
//Your file should be located in the working_directory under "Unicode/Unicode Plane 0.csv"
#macro UNICODE_DATA_CSV_FILE_PATH "Unicode/" //UnicodeData.csv
#macro UNICODE_DATA_CSV_FILE_NAME "UnicodeData.csv" //UnicodeData.csv

//Get data-structures of Unicode
global.grid_Unicode_CSV = -1;
global.map_Unicode_CSV = -1;
#macro UNICODE_LOOKUP_MODE_GRID 0
#macro UNICODE_LOOKUP_MODE_MAP 1
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

/// @description Load selected bundled Unicode planes into a raw table indexed by code point.
/// @param {Array<Real>} [_planes] Planes 0 through 16. Unloaded rows retain their code point columns.
/// @returns {Undefined}
function Unicode_set_grid_to_be_full_Unicode_table_and_use_grid_mode(_planes = UNICODE_PLANES_ALL)
{
    if (!is_array(_planes)) throw "Unicode planes must be an array.";
    for (var i = 0; i < array_length(_planes); ++i)
    {
        var requested_plane = _planes[i];
        if (!is_real(requested_plane) || requested_plane != floor(requested_plane)
            || requested_plane < 0 || requested_plane >= UNICODE_PLANE_COUNT)
            throw "Unicode plane must be an integer from 0 through 16.";
    }

    var next = ds_grid_create(enum_Unicode.length, UNICODE_PLANE_COUNT * UNICODE_PLANE_HEIGHT);
    try
    {
        ds_grid_clear(next, UNICODE_GRID_EMPTY_CELL_DEFAULT);
        for (var plane = 0; plane < UNICODE_PLANE_COUNT; ++plane)
        {
            var first = plane * UNICODE_PLANE_HEIGHT;
            if (array_contains(_planes, plane))
            {
                var path = UNICODE_PLANE_FILE_PATH + "Unicode Plane " + string(plane) + ".csv";
                var table = Unicode_load_legacy_csv(path, UNICODE_PLANE_HEIGHT);
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

/// @description Load the bundled compact UnicodeData table into a map keyed by code point.
/// @returns {Undefined}
function Unicode_set_map_to_be_UnicodeData_table_and_use_map_mode()
{
    var table = Unicode_load_legacy_csv(UNICODE_DATA_CSV_FILE_PATH + UNICODE_DATA_CSV_FILE_NAME);
    var next = ds_map_create();
    try
    {
        var row_count = ds_grid_height(table);
        for (var slot = 0; slot < row_count; ++slot)
        {
            var record = array_create(enum_Unicode.length);
            for (var field = 0; field < enum_Unicode.length; ++field)
                record[field] = table[# field, slot];
            ds_map_add(next, real(record[enum_Unicode.custom_ord_1]), record);
        }
    }
    catch (problem) { ds_map_destroy(next); throw problem; }
    finally { ds_grid_destroy(table); }
    Unicode_release_tables();
    global.map_Unicode_CSV = next;
    global.Unicode_lookup_mode = UNICODE_LOOKUP_MODE_MAP;
}

/// @param {Real} _mode UNICODE_LOOKUP_MODE_GRID or UNICODE_LOOKUP_MODE_MAP.
/// @param {Array<Real>} [_planes] Planes to include in grid mode.
/// @returns {Undefined}
function Unicode_set_mode(_mode, _planes = UNICODE_PLANES_ALL)
{
    if (_mode == UNICODE_LOOKUP_MODE_GRID)
        Unicode_set_grid_to_be_full_Unicode_table_and_use_grid_mode(_planes);
    else
    {
        if (_mode != UNICODE_LOOKUP_MODE_MAP) show_debug_message("Unknown Unicode lookup mode. Using map mode.");
        Unicode_set_map_to_be_UnicodeData_table_and_use_map_mode();
    }
}


// Legacy raw-table access is initialized explicitly with Unicode_set_mode().

#region Get useful General Categories for char filtering purposes.
/// @todo these need to be macros
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
global.arr_Unicode_whitespace_extra_ords = [9, 10, 11, 12, 13, 133, 6158]; // (U+0009 to U+000D, U+0085, U+180E) //Used with string_whitespace() Sadly, these whitespace chars are not represented properly in the General Categories as whitespace...

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
function Unicode_lookup_check_mode(_mode, _func)
{
	var err_str = "";
	if (_mode == UNICODE_LOOKUP_MODE_GRID)
	{
		//Ensure required grid exists
		if (!ds_exists(global.grid_Unicode_CSV,ds_type_grid))
		{err_str = string("Error in {0}. {1} is required to run {0}!",nameof(_func),nameof(global.grid_Unicode_CSV));}
	}
	else if (_mode == UNICODE_LOOKUP_MODE_MAP)
	{
		//Ensure required grid exists
		if (!ds_exists(global.map_Unicode_CSV,ds_type_map))
		{err_str = string("Error in {0}. {1} is required to run {0}!",nameof(_func),nameof(global.grid_Unicode_CSV));}
	}
	else
	{err_str = "An unknown error occurred with the Unicode functions!\r\nEnsure the UNICODE lookup mode is not being reset!";}
	
	if (err_str != "")
	{show_error(err_str,false);}
}


/// @function chr_Unicode
/// @description Ensures Unicode is within scope and that the chars can be used
/// @param {real} ord The char ordinal value
/// @returns {string}
/// @author Too many to list. Various online help guides and forum queries. et. al.
function chr_Unicode(_ord)
{
    // Ensure ord is within the valid Unicode range
    if (_ord < 0 || _ord > 0x10FFFF) 
    {
        return "";  // Return empty string for invalid ordinals
    }

    // If ord is a high surrogate (0xD800 to 0xDBFF) or low surrogate (0xDC00 to 0xDFFF), return empty string
    if ((_ord >= 0xD800 && _ord <= 0xDBFF) || (_ord >= 0xDC00 && _ord <= 0xDFFF))
    {
        return "";  // Return empty string for surrogate pairs
    }

    // If ord is U+10FFFF (non-character code point), return empty string
    if (_ord == 0x10FFFF)
    {
        return "";  // Return empty string for non-character code point
    }

    // Return the character corresponding to the valid ordinal
    return chr(_ord);
}

//New
/// @function string_char_at_get_as_usable_Unicode_surrogate
/// @description Returns the exact character at _pos. If a valid UTF-16 surrogate
///              pair (high + low) starts at _pos, returns the combined scalar.
///              If a lone surrogate is found, returns "�" (replacement char).
/// @param {string} _str  The input string
/// @param {real}   _pos  1-based position within the input string
/// @returns {string}     A valid character or the replacement char
/// @author The Games Re-creation Project.org (this new function was re-written by ChatGPT after some digging)
/// @license GNU
function string_char_at_get_as_usable_Unicode_surrogate(_str, _pos)
{
    var len = string_length(_str);
    if (len <= 0 || _pos < 1 || _pos > len) return "";

    // Get the character at the given position (GameMaker strings are UTF-8)
    var ch  = string_char_at(_str, _pos);
    if (ch == "") return "";

    var cp  = ord(ch);

    // Not in surrogate range → return as-is
    if (cp < 0xD800 || cp > 0xDFFF) {
        return ch;
    }

    // High surrogate: must be followed by a low surrogate
    if (cp >= 0xD800 && cp <= 0xDBFF) {
        if (_pos + 1 <= len) {
            var ch2 = string_char_at(_str, _pos + 1);
            if (ch2 != "") {
                var cp2 = ord(ch2);
                if (cp2 >= 0xDC00 && cp2 <= 0xDFFF) {
                    // Combine surrogate pair → one Unicode scalar
                    var full = (((cp - 0xD800) << 10) | (cp2 - 0xDC00)) + 0x10000;
                    return chr(full);
                }
            }
        }
        // Lone high surrogate → replacement char
        return "�";
    }

    // Lone low surrogate → replacement char
    return "�";
}


///// @function string_char_at_get_as_usable_Unicode_surrogate
///// @description Checks if the input char at the string position is a usable surrogate which is mapped to a Unicode char. If it's a lone surrogate, returns "".
///// @param {string} str The input string
///// @param {real}	pos The position within the input string
///// @returns {chr}
///// @author Too many to list. Various online help guides and forum queries. et. al. Note: Due to complexities, AI was consulted in the creation of this function.
///// @license GNU
//function string_char_at_get_as_usable_Unicode_surrogate(_str, _pos)
//{
//    // Get character at the given position
//    var _chr = string_char_at(_str, _pos),
//        _ord = ord(_chr),
//        surrogate_result = "";

//    // Check if the character is a valid high surrogate
//    if (_ord >= 0xD800 && _ord <= 0xDBFF)
//    {
//        // Check if the next character is within bounds and forms a valid low surrogate
//        if (_pos + 1 <= string_length(_str))
//        {
//            var _next_chr = string_char_at(_str, _pos + 1),
//                _next_ord = ord(_next_chr);

//            // If valid low surrogate, combine high and low surrogates into a Unicode character
//            if (_next_ord >= 0xDC00 && _next_ord <= 0xDFFF)
//            {
//                surrogate_result = chr((( (_ord - 0xD800) << 10 ) | (_next_ord - 0xDC00)) + 0x10000); // Combine to get code point
//                _pos++;  // Skip the low surrogate
//            }
//        }
//    }
//    // If it's a lone low surrogate, return an empty string
//    else if (_ord >= 0xDC00 && _ord <= 0xDFFF)
//    {
//        surrogate_result = "";
//    }
//    // For regular characters (not part of a surrogate pair), return the character
//    else
//    {
//        surrogate_result = _chr;
//    }

//    // Return either the surrogate pair or the regular character
//    return surrogate_result;
//}


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
