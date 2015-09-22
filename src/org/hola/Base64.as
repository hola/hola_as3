package org.hola
{
    import flash.utils.ByteArray;

    public class Base64 extends Object
    {
        private static const _decodeChars:Vector.<int> = InitDecodeChar();

        public static function decode(arr : ByteArray) : ByteArray {
            var c1 : int;
            var c2 : int;
            var c3 : int;
            var c4 : int;
            var i : int = 0;
            var len : int = arr.length;
            var pos : int = 0;
            while (i<len)
            {
                c1 = _decodeChars[int(arr[i++])];
                if (c1 == -1)
                    break;
                c2 = _decodeChars[int(arr[i++])];
                if (c2 == -1)
                    break;
                arr[int(pos++)] = (c1 << 2) | ((c2 & 0x30) >> 4);
                c3 = arr[int(i++)];
                if (c3 == 61)
                    break;
                c3 = _decodeChars[int(c3)];
                if (c3 == -1)
                    break;
                arr[int(pos++)] = ((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2);
                c4 = arr[int(i++)];
                if (c4 == 61)
                    break;
                c4 = _decodeChars[int(c4)];
                if (c4 == -1)
                    break;
                arr[int(pos++)] = ((c3 & 0x03) << 6) | c4;
            }
            arr.length = pos;
            return arr;
        }

        // intentionally not writing to ByteArray and reusing decode() for
        // performance
        public static function decode_str(str : String) : ByteArray {
            var c1 : int;
            var c2 : int;
            var c3 : int;
            var c4 : int;
            var i : int = 0;
            var len : int = str.length;
            var arr : ByteArray = new ByteArray();
            arr.length = len/4*3;
            var pos : int = 0;
            while (i<len)
            {
                c1 = _decodeChars[int(str.charCodeAt(i++))];
                if (c1 == -1)
                    break;
                c2 = _decodeChars[int(str.charCodeAt(i++))];
                if (c2 == -1)
                    break;
                arr[int(pos++)] = (c1 << 2) | ((c2 & 0x30) >> 4);
                c3 = int(str.charCodeAt(i++));
                if (c3 == 61)
                    break;
                c3 = _decodeChars[int(c3)];
                if (c3 == -1)
                    break;
                arr[int(pos++)] = ((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2);
                c4 = int(str.charCodeAt(i++));
                if (c4 == 61)
                    break;
                c4 = _decodeChars[int(c4)];
                if (c4 == -1)
                    break;
                arr[int(pos++)] = ((c3 & 0x03) << 6) | c4;
            }
            arr.length = pos;
            return arr;
        }

        public static function InitDecodeChar() : Vector.<int>
        {
            var decodeChars : Vector.<int> = new <int>[
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
                52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
                -1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
                15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
                -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
                41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];
            return decodeChars;
        }
    }
}
