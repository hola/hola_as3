package org.hola {
    import flash.external.ExternalInterface;
    CONFIG::HAVE_WORKER {
    import flash.system.Worker;
    }

    public class HSettings {
        private static var _inited : Boolean = false;
        private static var _use_worker : Boolean = false;
        public static var hls_mode : Boolean = false;
        public static var managed : Boolean = false;

        public static function get use_worker() : Boolean {
            CONFIG::HAVE_WORKER {
            return Worker.isSupported && _use_worker;
            }
            return false;
        }

        public static function set use_worker(b : Boolean) : void {
            _use_worker = b;
        }

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
                    case "use_worker": use_worker = !!s[k]; break;
                }
            }
            return {
                hls_mode: hls_mode,
                managed: managed,
                use_worker: use_worker
            };
        }
    }
}
