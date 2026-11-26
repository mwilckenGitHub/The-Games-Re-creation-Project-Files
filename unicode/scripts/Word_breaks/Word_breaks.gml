/// @ignore Word break property values stored in bits 12 through 16.
enum Word_class
{
    ordinary, cr, lf, newline, extend, format_char, zwj, space_run, letter, hebrew, numeric,
    katakana, connector, mid_letter, mid_number, mid_both, single_quote, double_quote, regional
}

/// @description Unicode 18 default word boundaries, expressed as zero-based scalar offsets.
/// @returns {Struct.Word_breaks} Reusable word segmenter.
function Word_breaks() : Text_properties() constructor
{
    /// @param {String} _text Text to segment without normalization.
    /// @returns {Array<Real>} Sorted word, punctuation and whitespace segment boundaries, including both ends.
    static boundaries = function(_text)
    {
        if (!is_string(_text)) throw "Word boundaries require a string.";
        var count = string_length(_text);
        if (count == 0) return [0];
        var lookup = method(self, properties);
        var data = {values: array_create(count), lookup_scalar: lookup};
        string_foreach(_text, method(data, function(_char, _position) {
            values[_position - 1] = lookup_scalar(ord(_char));
        }));
        return break_flags(data.values);
    };

    /// @param {Array<Real>} _scalars Unicode scalars, including U+0000.
    /// @returns {Array<Real>} Default word boundary offsets.
    static boundaries_for_scalars = function(_scalars)
    {
        var values = array_create(array_length(_scalars));
        for (var i = 0; i < array_length(values); ++i) values[i] = properties(_scalars[i]);
        return break_flags(values);
    };

    /// @ignore Apply UAX #29 word rules in linear time after property lookup.
    static break_flags = function(_values)
    {
        var count = array_length(_values);
        if (count == 0) return [0];
        var next_class = array_create(count);
        var following = Word_class.ordinary;
        for (var i = count - 1; i >= 0; --i)
        {
            next_class[i] = following;
            var current = (_values[i] >> 12) & 31;
            if (!ignorable(current)) following = current;
        }
        var offsets = [0];
        var before = Word_class.ordinary, previous = Word_class.ordinary;
        var regional_odd = false;
        for (var i = 1; i < count; ++i)
        {
            var immediate = (_values[i-1] >> 12) & 31;
            if (!ignorable(immediate))
            {
                before = previous;
                previous = immediate;
                regional_odd = immediate == Word_class.regional && !regional_odd;
            }
            var flags = _values[i];
            var current = (flags >> 12) & 31;
            if (immediate == Word_class.cr && current == Word_class.lf) continue;
            if (line_break(immediate) || line_break(current)) { array_push(offsets, i); continue; }
            if (immediate == Word_class.zwj && (flags & 256) != 0) continue;
            if (immediate == Word_class.space_run && current == Word_class.space_run) continue;
            if (ignorable(current)) continue;
            if (letters(previous) && letters(current)) continue;
            if (letters(previous) && letter_punctuation(current) && letters(next_class[i])) continue;
            if (letters(before) && letter_punctuation(previous) && letters(current)) continue;
            if (previous == Word_class.hebrew && current == Word_class.single_quote) continue;
            if (previous == Word_class.hebrew && current == Word_class.double_quote && next_class[i] == Word_class.hebrew) continue;
            if (before == Word_class.hebrew && previous == Word_class.double_quote && current == Word_class.hebrew) continue;
            if (previous == Word_class.numeric && (current == Word_class.numeric || letters(current))) continue;
            if (letters(previous) && current == Word_class.numeric) continue;
            if (before == Word_class.numeric && number_punctuation(previous) && current == Word_class.numeric) continue;
            if (previous == Word_class.numeric && number_punctuation(current) && next_class[i] == Word_class.numeric) continue;
            if (previous == Word_class.katakana && current == Word_class.katakana) continue;
            if (current == Word_class.connector && (word_body(previous) || previous == Word_class.connector)) continue;
            if (previous == Word_class.connector && word_body(current)) continue;
            if (current == Word_class.regional && regional_odd) continue;
            array_push(offsets, i);
        }
        array_push(offsets, count);
        return offsets;
    };

    /// @ignore Helpers group the properties used by the UAX #29 word rules.
    static letters = function(_class) { return _class == Word_class.letter || _class == Word_class.hebrew; };
    static word_body = function(_class) { return letters(_class) || _class == Word_class.numeric || _class == Word_class.katakana; };
    static line_break = function(_class) { return _class >= Word_class.cr && _class <= Word_class.newline; };
    static ignorable = function(_class) { return _class >= Word_class.extend && _class <= Word_class.zwj; };
    static letter_punctuation = function(_class) {
        return _class == Word_class.mid_letter || _class == Word_class.mid_both || _class == Word_class.single_quote;
    };
    static number_punctuation = function(_class) {
        return _class == Word_class.mid_number || _class == Word_class.mid_both || _class == Word_class.single_quote;
    };
}
