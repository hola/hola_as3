package org.hola
{
    import flash.external.ExternalInterface;
    public class ZExternalInterface
    {
        private static var is_avail:Boolean = false;
        private static var inited:Boolean = false;

        public static function avail():Boolean{
            if (!inited)
            {
                try {
                    // ExternalInterface.available may be true even if
                    // allowScriptAccess is never
                    ExternalInterface.call('Date.now');
                    is_avail = ExternalInterface.available;
                } catch(err:Error){
                    is_avail = false;
                }
            }
            inited = true;
            return is_avail;
        }
    }
}
