/// @ignore Values in the low byte of Unicode/graphemes.csv.
enum Grapheme_class
{
    ordinary, cr, lf, control_char, extend, zwj, regional, prepend, spacing_mark,
    hangul_l, hangul_v, hangul_t, hangul_lv, hangul_lvt
}

/// @description Unicode 18 extended grapheme boundaries, expressed as zero-based scalar offsets.
/// @returns {Struct.Graphemes} Reusable segmenter sharing one immutable property table.
function Graphemes() : Text_properties() constructor
{
    /// @ignore The scan object holds only the previous class and the prefixes required by UAX #29.
    static accept_scalar = function(flags, _position)
    {
        var current = flags & 255;
        var pictograph = (flags & 256) != 0;
        var boundary = true;
        if (_position > 1)
        {
            if (previous == Grapheme_class.cr && current == Grapheme_class.lf) boundary = false;
            else if (previous >= Grapheme_class.cr && previous <= Grapheme_class.control_char) boundary = true;
            else if (current >= Grapheme_class.cr && current <= Grapheme_class.control_char) boundary = true;
            else if (previous == Grapheme_class.hangul_l && (current == Grapheme_class.hangul_l
                || current == Grapheme_class.hangul_v || current == Grapheme_class.hangul_lv
                || current == Grapheme_class.hangul_lvt)) boundary = false;
            else if ((previous == Grapheme_class.hangul_lv || previous == Grapheme_class.hangul_v)
                && (current == Grapheme_class.hangul_v || current == Grapheme_class.hangul_t)) boundary = false;
            else if ((previous == Grapheme_class.hangul_lvt || previous == Grapheme_class.hangul_t)
                && current == Grapheme_class.hangul_t) boundary = false;
            else if (current == Grapheme_class.extend || current == Grapheme_class.zwj
                || current == Grapheme_class.spacing_mark || previous == Grapheme_class.prepend) boundary = false;
            else if ((flags & 2048) != 0 && after_linker) boundary = false;
            else if (pictograph && after_pictograph_joiner) boundary = false;
            else if (current == Grapheme_class.regional && regional_odd) boundary = false;
            if (boundary) array_push(offsets, _position - 1);
        }
        after_linker = (flags & 512) != 0 || (after_linker && (flags & 1024) != 0);
        after_pictograph_joiner = pictograph_prefix && current == Grapheme_class.zwj;
        pictograph_prefix = pictograph || (pictograph_prefix && current == Grapheme_class.extend);
        regional_odd = current == Grapheme_class.regional && !regional_odd;
        previous = current;
    };

    /// @param {String} _text Text to segment without normalization.
    /// @returns {Array<Real>} Sorted insertion positions, including both ends. Empty text returns [0].
    static boundaries = function(_text)
    {
        if (!is_string(_text)) throw "Grapheme boundaries require a string.";
        var scan = new_scan();
        string_foreach(_text, method(scan, function(_char, _position) {
            consume(lookup_scalar(ord(_char)), _position);
        }));
        var count = string_length(_text);
        if (count > 0) array_push(scan.offsets, count);
        return scan.offsets;
    };

    /// @param {Array<Real>} _scalars Unicode scalars, including U+0000 from byte-oriented inputs.
    /// @returns {Array<Real>} Extended grapheme cluster boundaries in scalar offsets.
    static boundaries_for_scalars = function(_scalars)
    {
        var scan = new_scan();
        var count = array_length(_scalars);
        for (var i = 0; i < count; ++i) scan.consume(properties(_scalars[i]), i + 1);
        if (count > 0) array_push(scan.offsets, count);
        return scan.offsets;
    };

    /// @ignore Create independent state for one scan.
    static new_scan = function()
    {
        var lookup = method(self, properties);
        var scan = {lookup_scalar: lookup, offsets: [0], previous: -1, regional_odd: false,
            after_linker: false, pictograph_prefix: false, after_pictograph_joiner: false};
        scan.consume = method(scan, accept_scalar);
        return scan;
    };

    /// @param {Array<Real>} _offsets Sorted scalar offsets.
    /// @param {Real} _position Requested insertion offset.
    /// @param {Bool} [_forward] Snap forward inside a cluster, otherwise backward.
    /// @returns {Real} Index into the offsets array.
    static boundary_index = function(_offsets, _position, _forward = false)
    {
        var low = 0, high = array_length(_offsets) - 1;
        while (low <= high)
        {
            var mid = (low + high) div 2;
            if (_offsets[mid] < _position) low = mid + 1;
            else if (_offsets[mid] > _position) high = mid - 1;
            else return mid;
        }
        return clamp(_forward ? low : high, 0, array_length(_offsets) - 1);
    };

}
