/// @ignore Immutable shared Unicode 18 property ranges used for segmentation, classification and casing.
function Text_properties() constructor
{
    static tables = {ranges: undefined};

    /// @ignore Look up a scalar's grapheme class and contextual property flags.
    static properties = function(_scalar)
    {
        var rows = tables.ranges;
        var low = 0, high = array_length(rows) - 1;
        while (low <= high)
        {
            var mid = (low + high) div 2;
            var row = rows[mid];
            if (_scalar < row[0]) high = mid - 1;
            else if (_scalar > row[1]) low = mid + 1;
            else return row[2];
        }
        return 0;
    };

    if (is_undefined(tables.ranges))
    {
        var handle = file_text_open_read("Unicode/text-properties.csv");
        if (handle < 0) throw "The Unicode character property table is unavailable.";
        var rows = [];
        try
        {
            while (!file_text_eof(handle))
            {
                var line = file_text_read_string(handle);
                file_text_readln(handle);
                if (line == "") continue;
                var fields = string_split(line, ",");
                if (array_length(fields) != 3) throw "Invalid Unicode character property row.";
                array_push(rows, [real(fields[0]), real(fields[1]), real(fields[2])]);
            }
            if (array_length(rows) == 0) throw "The Unicode character property table is empty.";
        }
        finally { file_text_close(handle); }
        tables.ranges = rows;
    }
}
