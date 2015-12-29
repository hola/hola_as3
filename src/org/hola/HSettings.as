package org.hola {
    import flash.external.ExternalInterface;

    public class HSettings {
        private static var _inited : Boolean = false;
        public static var hls_mode : Boolean = false;
        public static var managed : Boolean = false;

        public static function init() : void {
            if (_inited || !ZExternalInterface.avail())
                return;
            _inited = true;
            ExternalInterface.addCallback("hola_settings", settings);
        }

        private static function settings(s : Object) : Object {
            for (var k : String in s)
            {
                switch (k)
                {
                    case "hls_mode": hls_mode = !!s[k]; break;
                    case "managed": managed = !!s[k]; break;
                }
            }
            return {
                hls_mode: hls_mode,
                managed: managed
            };
        }
    }
}
