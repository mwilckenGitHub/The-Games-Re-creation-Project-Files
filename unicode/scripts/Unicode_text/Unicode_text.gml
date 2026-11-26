/// @description Unicode 18 general categories and locale-neutral full case mapping.
/// @returns {Struct.Unicode_text} Reusable reader for character and case data.
function Unicode_text() : Text_properties() constructor
{
    static categories = ["Cn","Lu","Ll","Lt","Lm","Lo","Mn","Mc","Me","Nd","Nl","No","Pc","Pd","Ps","Pe","Pi","Pf","Po",
        "Sm","Sc","Sk","So","Zs","Zl","Zp","Cc","Cf","Cs","Co"];
    static case_data = {mappings: undefined};
    word_reader = new Word_breaks();

    /// @param {Real} _scalar Unicode code point.
    /// @returns {String} Two-letter Unicode general category.
    static general_category = function(_scalar) { return categories[(properties(_scalar) >> 17) & 31]; };

    /// @param {String} _text String to filter.
    /// @param {Array<String>} _categories General categories or one-letter category families.
    /// @param {Bool} [_unknown] Include unassigned code points for legacy callers.
    /// @returns {String} Original characters whose categories match.
    static filter_categories = function(_text, _categories, _unknown = false)
    {
        var category_of = method(self, general_category);
        var state = {parts: [], allowed: _categories, unknown: _unknown, category_for: category_of};
        string_foreach(_text, method(state, function(_char, _position) {
            var category = category_for(ord(_char));
            if ((unknown && category == "Cn") || array_contains(allowed, category)
                || array_contains(allowed, string_char_at(category, 1))) array_push(parts, _char);
        }));
        return string_join_ext("", state.parts);
    };

    /// @param {String} _text Input string.
    /// @returns {String} Original characters having the Unicode White_Space property.
    static whitespace = function(_text)
    {
        var lookup = method(self, properties);
        var state = {parts: [], lookup_scalar: lookup};
        string_foreach(_text, method(state, function(_char, _position) {
            if ((lookup_scalar(ord(_char)) & (1 << 22)) != 0) array_push(parts, _char);
        }));
        return string_join_ext("", state.parts);
    };

    /// @param {String} _text Source text.
    /// @param {String} _style One of "lower", "upper", or "title".
    /// @returns {String} Full Unicode case mapping, including expansions and contextual final sigma.
    static change_case = function(_text, _style)
    {
        if (!is_string(_text) || !array_contains(["upper","lower","title"], _style)) throw "Invalid Unicode casing request.";
        if (_text == "") return "";
        var lookup = method(self, properties);
        var size = string_length(_text);
        var state = {chars: array_create(size), properties_by_char: array_create(size), lookup_scalar: lookup};
        string_foreach(_text, method(state, function(_char, _position) {
            chars[_position - 1] = _char;
            properties_by_char[_position - 1] = lookup_scalar(ord(_char));
        }));
        var spans = _style == "title" ? word_reader.boundaries(_text) : [0, size];
        var span_index = 0, leading = true, preceded_by_cased = false;
        var after = array_create(size, false);
        var next_cased = false;
        for (var i = size - 1; i >= 0; --i)
        {
            after[i] = next_cased;
            var flags = state.properties_by_char[i];
            if ((flags & (1 << 24)) == 0) next_cased = (flags & (1 << 23)) != 0;
        }
        for (var i = 0; i < size; ++i)
        {
            if (i == spans[span_index]) { leading = true; span_index++; }
            var flags = state.properties_by_char[i];
            var cased = (flags & (1 << 23)) != 0;
            var scalar = ord(state.chars[i]);
            var mode = _style == "upper" ? 1 : 0;
            if (_style == "title" && leading)
            {
                if (!cased)
                {
                    if ((flags & (1 << 24)) == 0) preceded_by_cased = false;
                    continue;
                }
                mode = 2;
                leading = false;
            }
            var mapping = case_data.mappings[$ string(scalar)];
            if (mode == 0 && scalar == $03A3 && preceded_by_cased && !after[i]) state.chars[i] = chr($03C2);
            else if (is_array(mapping)) state.chars[i] = mapping[mode];
            if ((flags & (1 << 24)) == 0) preceded_by_cased = cased;
        }
        return string_join_ext("", state.chars);
    };

    if (is_undefined(case_data.mappings))
    {
        var handle = file_text_open_read("Unicode/case-mappings.csv");
        if (handle < 0) throw "The Unicode case mapping table is unavailable.";
        var mappings = {};
        try
        {
            while (!file_text_eof(handle))
            {
                var line = file_text_read_string(handle);
                file_text_readln(handle);
                if (line == "") continue;
                var fields = string_split(line, ",");
                var outputs = [];
                for (var column = 1; column <= 3; ++column)
                {
                    var units = string_split(fields[column], " ");
                    var mapped = "";
                    for (var j = 0; j < array_length(units); ++j) mapped += chr(real(units[j]));
                    array_push(outputs, mapped);
                }
                mappings[$ fields[0]] = outputs;
            }
        }
        finally { file_text_close(handle); }
        case_data.mappings = mappings;
    }
}


/// @description Fold Unicode case differences for locale-neutral matching.
/// @param {String} _text Original text.
/// @returns {String} A search key using the Unicode common and full case-fold mappings.
function unicode_casefold(_text)
{
    if (string_byte_length(_text)==string_length(_text)) return string_lower(_text);
    static folds=undefined;
    if (is_undefined(folds))
    {
        var handle=file_text_open_read("Unicode/case-folding.csv");
        if (handle<0) throw "The Unicode case folding table is unavailable.";
        var mappings={};
        try
        {
            while (!file_text_eof(handle))
            {
                var line=file_text_read_string(handle);
                file_text_readln(handle);
                if (line=="") continue;
                var fields=string_split(line,",");
                var units=string_split(fields[1]," "), folded="";
                for (var i=0; i<array_length(units); ++i) folded+=chr(real(units[i]));
                mappings[$ fields[0]]=folded;
            }
        }
        finally { file_text_close(handle); }
        folds=mappings;
    }
    var state={mappings:folds,parts:[]};
    string_foreach(_text,method(state,function(_char,_position)
    {
        array_push(parts,mappings[$ string(ord(_char))] ?? _char);
    }));
    return string_join_ext("",state.parts);
}

/// @description Compare canonically equivalent text using locale-neutral full case folding.
/// @param {String} _text Text from a query, caption or description.
/// @returns {String} A composed search key.
function unicode_search_key(_text)
{
    if (string_byte_length(_text) == string_length(_text)) return string_lower(_text);
    var normalizer = unicode_normalizer();
    return normalizer.nfc(unicode_casefold(normalizer.nfd(_text)));
}

/// @description Compose canonically equivalent characters for display while preserving case.
/// @param {String} _text Original text.
/// @returns {String} The equivalent text in Unicode NFC.
function unicode_nfc(_text)
{
    if (string_byte_length(_text) == string_length(_text)) return _text;
    return unicode_normalizer().nfc(_text);
}

/// @ignore Load normalization data only when non-ASCII text needs it.
function unicode_normalizer()
{
    static normalizer = new Unicode_normalizer();
    return normalizer;
}

/// @ignore Canonical decomposition, ordering and composition from the bundled Unicode data.
function Unicode_normalizer() constructor
{
    ranks = {};
    decompositions = {};
    compositions = {};

    static syllable_base = $AC00;
    static lead_base = $1100;
    static vowel_base = $1161;
    static tail_base = $11A7;
    static lead_count = 19;
    static vowel_count = 21;
    static tail_count = 28;
    static syllables_per_lead = 588;
    static syllable_count = 11172;

    /// @ignore Insert a non-starter after equal classes and before larger classes in its run.
    static append_ordered = function(_ordered, _point)
    {
        var rank = ranks[$ string(_point)] ?? 0;
        var slot = array_length(_ordered);
        var entry = [_point, rank];
        array_push(_ordered, entry);
        while (rank != 0 && slot > 0 && _ordered[slot - 1][1] > rank)
        {
            _ordered[@ slot] = _ordered[slot - 1];
            --slot;
        }
        _ordered[@ slot] = entry;
    };

    static decompose = function(_ordered, _point)
    {
        var syllable = _point - syllable_base;
        if (syllable >= 0 && syllable < syllable_count)
        {
            append_ordered(_ordered, lead_base + (syllable div syllables_per_lead));
            append_ordered(_ordered, vowel_base + ((syllable div tail_count) mod vowel_count));
            var tail = syllable mod tail_count;
            if (tail != 0) append_ordered(_ordered, tail_base + tail);
            return;
        }

        var mapping = decompositions[$ string(_point)];
        if (is_undefined(mapping)) append_ordered(_ordered, _point);
        else
            for (var i = 0; i < array_length(mapping); ++i) decompose(_ordered, mapping[i]);
    };

    static ordered_points = function(_text)
    {
        var decompose_point = method(self, decompose);
        var scan = { ordered: [], append_decomposition: decompose_point };
        string_foreach(_text, method(scan, function(_char, _position)
        {
            append_decomposition(ordered, ord(_char));
        }));
        return scan.ordered;
    };

    /// @returns {String} The canonical decomposition of the input.
    static nfd = function(_text)
    {
        var ordered = ordered_points(_text);
        var chars = array_map(ordered, function(_unit, _index) { return chr(_unit[0]); });
        return string_join_ext("", chars);
    };

    /// @ignore Hangul joins L+V and LV+T, including when the second scalar is a starter.
    static compose_pair = function(_first, _second)
    {
        var lead = _first - lead_base, vowel = _second - vowel_base;
        if (lead >= 0 && lead < lead_count && vowel >= 0 && vowel < vowel_count)
            return syllable_base + lead * syllables_per_lead + vowel * tail_count;

        var syllable = _first - syllable_base, tail = _second - tail_base;
        if (syllable >= 0 && syllable < syllable_count && (syllable mod tail_count) == 0
            && tail > 0 && tail < tail_count)
            return _first + tail;

        return compositions[$ string(_first) + "/" + string(_second)];
    };

    /// @returns {String} The canonical composition of the input.
    static nfc = function(_text)
    {
        var ordered = ordered_points(_text);
        var output = [];
        var starter = -1, previous_rank = 0;
        for (var i = 0; i < array_length(ordered); ++i)
        {
            var unit = ordered[i], point = unit[0], rank = unit[1];
            if (starter >= 0 && (previous_rank == 0 || previous_rank < rank))
            {
                var composite = compose_pair(output[starter], point);
                if (!is_undefined(composite))
                {
                    output[starter] = composite;
                    continue;
                }
            }
            if (rank == 0) starter = array_length(output);
            array_push(output, point);
            previous_rank = rank;
        }
        var chars = array_map(output, function(_point, _index) { return chr(_point); });
        return string_join_ext("", chars);
    };

    var handle = file_text_open_read("Unicode/canonical-normalization.csv");
    if (handle < 0) throw "The Unicode normalization table is unavailable.";
    try
    {
        while (!file_text_eof(handle))
        {
            var line = file_text_read_string(handle);
            file_text_readln(handle);
            if (line == "") continue;
            var fields = string_split(line, ",");
            var rank = real(fields[1]);
            if (rank != 0) ranks[$ fields[0]] = rank;
            if (fields[2] == "-") continue;

            var mapping = array_map(string_split(fields[2], " "), function(_unit, _index) { return real(_unit); });
            decompositions[$ fields[0]] = mapping;
            if (fields[3] == "1")
                compositions[$ string(mapping[0]) + "/" + string(mapping[1])] = real(fields[0]);
        }
    }
    finally { file_text_close(handle); }
}
