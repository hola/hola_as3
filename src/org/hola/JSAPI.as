package org.hola
{
    import flash.external.ExternalInterface;
    import flash.utils.setTimeout;

    public class JSAPI
    {
        private static var _inited:Boolean = false;

        public static function init():void{
            if (_inited || !ZExternalInterface.avail())
                return;
            _inited = true;
            HSettings.init();
            FetchBin.init();
            ExternalInterface.addCallback("hola_setTimeout", set_timeout);
            ExternalInterface.addCallback("hola_version_swc", version);
        }

        private static function set_timeout(ms: Number, id: String): void
	{
            setTimeout(function(): void
	    {
	        postMessage('hola_timeout', {timeout_id: id});
	    }, ms);
        }

        public static function version():String{
            return CONFIG::HOLA_AS3_VERSION;
        }

        public static function postMessage(id: String, data: Object):void
	{
            if (!ZExternalInterface.avail())
                return;
            ExternalInterface.call("window.postMessage", {id: id, player_id: HSettings.gets("player_id"), data: data}, "*");
        }
    }
}
