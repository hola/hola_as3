package org.hola
{
    import flash.external.ExternalInterface;
    import flash.utils.setTimeout;
    import org.hola.ZExternalInterface;
    import org.hola.HSettings;

    public class JSAPI
    {
        private static var _inited:Boolean = false;

        public static function init():void{
            if (_inited || !ZExternalInterface.avail())
                return;
            _inited = true;
            HSettings.init();
            FlashFetchBin.init();
            ExternalInterface.addCallback("hola_setTimeout", set_timeout);
            ExternalInterface.addCallback("hola_version_swc", version);
        }

        private static function set_timeout(ms:Number):void{
            setTimeout(on_timeout, ms);
        }

        private static function on_timeout():void{
            ExternalInterface.call("window.hola_onTimeout");
        }

        public static function version():String{
            return CONFIG::HOLA_AS3_VERSION;
        }
    }
}
