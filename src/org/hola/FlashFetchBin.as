package org.hola {
    import flash.events.*;
    import flash.net.URLStream;
    import flash.net.URLRequest;
    import flash.external.ExternalInterface;
    import org.hola.ZExternalInterface;

    public class FlashFetchBin {
        private static var inited:Boolean = false;
        private static var free_id:Number = 0;
        public static var req_list:Object = {};

        public static function init():Boolean{
            if (inited)
                return inited;
            if (!ZExternalInterface.avail())
                return false;
            ExternalInterface.addCallback('hola_fetchBin', hola_fetchBin);
            ExternalInterface.addCallback('hola_fetchBinRemove',
                hola_fetchBinRemove);
            ExternalInterface.addCallback('hola_fetchBinAbort',
                hola_fetchBinAbort);
            inited = true;
            return inited;
        }

        private static function hola_fetchBin(o:Object):Object{
            var id:String = 'fetch_bin_'+free_id;
            free_id++;
            var url:String = o.url;
            var req:URLRequest = new URLRequest(url);
            var stream:URLStream = new URLStream();
            stream.load(req);
            req_list[id] = {id: id, stream: stream,
                jsurlstream_req_id: o.jsurlstream_req_id};
            stream.addEventListener(Event.OPEN, streamOpen);
            stream.addEventListener(ProgressEvent.PROGRESS, streamProgress);
            stream.addEventListener(HTTPStatusEvent.HTTP_STATUS,
                streamHttpStatus);
            stream.addEventListener(Event.COMPLETE, streamComplete);
            stream.addEventListener(IOErrorEvent.IO_ERROR, streamError);
            stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,
                streamError);
            return {id: id, url: url};
        }

        public static function hola_fetchBinRemove(id:String):void{
            var req:Object = req_list[id];
            if (!req)
                return;
            if (req.stream.connected)
                req.stream.close();
            delete req_list[id];
        }

        private static function hola_fetchBinAbort(id:String):void{
            var req:Object = req_list[id];
            if (!req)
                return;
            if (req.stream.connected)
                req.stream.close();
        }

        private static function getReqFromStream(stream:Object):Object{
            // XXX arik/bahaa: implement without loop
            for (var n:String in req_list)
            {
                if (req_list[n].stream===stream)
                    return req_list[n];
            }
            return null;
        }

        // XXX arik/bahaa: mv to org.hola.util
        private static function jsPostMessage(id:String, data:Object):void{
            if (!ZExternalInterface.avail())
                return;
            ExternalInterface.call('window.postMessage',
                {id: id, ts: new Date().getTime(), data: data}, '*');
        }

        private static function streamOpen(e:Event):void{
            var req:Object = getReqFromStream(e.target);
            if (!req)
                return ZErr.log('req not found streamOpen');
            jsPostMessage('holaflash.streamOpen', {id: req.id});
        }

        private static function streamProgress(e:ProgressEvent):void{
            var req:Object = getReqFromStream(e.target);
            if (!req)
                return ZErr.log('req not found streamProgress');
            req.bytesTotal = e.bytesTotal;
            req.bytesLoaded = e.bytesLoaded;
            if (!req.prevJSProgress || req.bytesLoaded==req.bytesTotal ||
                req.bytesLoaded-req.prevJSProgress > (req.bytesTotal/5))
            {
                req.prevJSProgress = req.bytesLoaded;
                jsPostMessage('holaflash.streamProgress', {id: req.id,
                    bytesLoaded: e.bytesLoaded, bytesTotal: e.bytesTotal});
            }
        }

        private static function streamHttpStatus(e:HTTPStatusEvent):void{
            var req:Object = getReqFromStream(e.target);
            if (!req)
                return ZErr.log('req not found streamHttpStatus');
            jsPostMessage('holaflash.streamHttpStatus', {id: req.id,
                status: e.status});
        }

        private static function streamComplete(e:Event):void{
            var req:Object = getReqFromStream(e.target);
            if (!req)
                return ZErr.log('req not found streamComplete');
            jsPostMessage('holaflash.streamComplete', {id: req.id,
                bytesTotal: req.bytesTotal});
        }

        private static function streamError(e:ErrorEvent):void{
            var req:Object = getReqFromStream(e.target);
            if (!req)
                return ZErr.log('req not found streamError');
            jsPostMessage('holaflash.streamError', {id: req.id});
            hola_fetchBinRemove(req.id);
        }
    }
}
