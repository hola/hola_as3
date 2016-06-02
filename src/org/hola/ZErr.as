package org.hola
{
    import flash.external.ExternalInterface;
    public class ZErr
    {
       private static var _sendScript:XML = <script><![CDATA[
function(l, s) {
    try {
        function level_to_console(level){
            switch (level){
            case 'crit': return 'error';
            case 'err': return 'error';
            case 'warn': return 'warn';
            case 'notice': return 'log';
            case 'info': return 'info';
            case 'debug': return zutil.is_mocha() ? 'info' : 'debug';
            default:
                  console.error('invalid level', level);
                  return 'error';
            }
        }
        var log = window.hola_cdn && window.hola_cdn.log;
        if (log && log[l])
            log[l](s);
        else
            console[level_to_console(l)](s);
    } catch(err){}
}]]></script>;
        public static function crit(msg:String, ...rest:Array):void{
            if (!ZExternalInterface.avail())
                return;
            ExternalInterface.call.apply(ExternalInterface,
                [_sendScript, 'crit', msg+' '+rest.join(' ')]);
        }
        public static function err(msg:String, ...rest:Array):void{
            if (!ZExternalInterface.avail())
                return;
            ExternalInterface.call.apply(ExternalInterface,
                [_sendScript, 'err', msg+' '+rest.join(' ')]);
        }
        public static function warn(msg:String, ...rest:Array):void{
            if (!ZExternalInterface.avail())
                return;
            ExternalInterface.call.apply(ExternalInterface,
                [_sendScript, 'warn', msg+' '+rest.join(' ')]);
        }
        public static function notice(msg:String, ...rest:Array):void{
            if (!ZExternalInterface.avail())
                return;
            ExternalInterface.call.apply(ExternalInterface,
                [_sendScript, 'notice', msg+' '+rest.join(' ')]);
        }
        public static function info(msg:String, ...rest:Array):void{
            if (!ZExternalInterface.avail())
                return;
            ExternalInterface.call.apply(ExternalInterface,
                [_sendScript, 'info', msg+' '+rest.join(' ')]);
        }
        public static function debug(msg:String, ...rest:Array):void{
            if (!ZExternalInterface.avail())
                return;
            ExternalInterface.call.apply(ExternalInterface,
                [_sendScript, 'debug', msg+' '+rest.join(' ')]);
        }
    }
}
