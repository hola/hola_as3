package org.hola {
    import flash.external.ExternalInterface;
    import org.hola.ZExternalInterface;
    CONFIG::HAVE_WORKER {
    import flash.system.Worker;
    }

    public class HSettings {
        private static var _inited : Boolean = false;
        private static var _use_worker : Boolean = false;
        public static var hls_mode : Boolean = false;
        public static var managed : Boolean = false;
        public static var fetch_bin_chunk_size : Number = 128*1024;
        public static var fetch_bin_delay : Number = 20;
        public static var version : String = CONFIG::HOLA_AS3_VERSION;

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
                    case "fetch_bin_chunk_size":
                        fetch_bin_chunk_size = s[k];
                        break;
                    case "fetch_bin_delay": fetch_bin_delay = s[k]; break;
                    case "use_worker": use_worker = !!s[k]; break;
                }
            }
            return {
                hls_mode: hls_mode,
                managed: managed,
                fetch_bin_chunk_size: fetch_bin_chunk_size,
                fetch_bin_delay: fetch_bin_delay,
                use_worker: use_worker
            };
        }
    }
}
