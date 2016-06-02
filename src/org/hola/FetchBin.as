package org.hola {
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.net.URLRequest;
    import flash.net.URLStream;
    import org.hola.HSettings;

    public class FetchBin extends URLStream {
        private static var inited:Boolean = false;
        private static var free_id:Number = 0;
        private static var req_list:Object = {};
        private var _jsurlstream:JSURLStream;
        private var _jsurlstream_id:String;
        private var _prev_js_progress:uint;
        public var id:String;
        public var bytesLoaded:uint;
        public var bytesTotal:uint;
        public var bytesRead:uint;
	public var is_rate: Boolean;

        public static function init():void{
            if (inited || !ZExternalInterface.avail())
                return;
            inited = true;
            ExternalInterface.addCallback('hola_fetchBin', fetch);
            ExternalInterface.addCallback('hola_fetchBinRemove', remove);
        }

        private static function fetch(o:Object):Object{
            var f:FetchBin = new FetchBin(o);
            return {id: f.id, url: o.url};
        }

        public static function get(id:String):FetchBin{
            return req_list[id];
        }

        public static function remove(id:String):void{
            var req:FetchBin = get(id);
            if (!req)
                return;
            if (req.connected)
                req.close();
            req._delete();
        }

        public function FetchBin(o:Object){
	    is_rate = !!o.rate;
            id = 'fetch_bin_'+HSettings.gets('player_id')+'_'+(free_id++);
            req_list[id] = this;
            if ((_jsurlstream_id = o.jsurlstream_req_id))
                _jsurlstream = JSURLStream.get(o.jsurlstream_req_id);
            super.load(new URLRequest(o.url));
            addEventListener(Event.OPEN, onopen);
            addEventListener(ProgressEvent.PROGRESS, onprogress);
            addEventListener(HTTPStatusEvent.HTTP_STATUS, onstatus);
            addEventListener(Event.COMPLETE, oncomplete);
            addEventListener(IOErrorEvent.IO_ERROR, onerror);
            addEventListener(SecurityErrorEvent.SECURITY_ERROR, onerror);
        }

        private function _delete():void{
            delete req_list[id];
        }

        private function onopen(e:Event):void{
            JSAPI.postMessage('holaflash.streamOpen', {fb_id: id});
        }

        public function read_ack(bytes:uint):void{
            bytesRead += bytes;
        }

        private function onprogress(e:ProgressEvent):void{
            bytesTotal = e.bytesTotal;
            bytesLoaded = e.bytesLoaded;
            if (!_prev_js_progress || bytesLoaded==bytesTotal ||
                bytesLoaded-_prev_js_progress > bytesTotal/5)
            {
                _prev_js_progress = bytesLoaded;
                JSAPI.postMessage('holaflash.streamProgress', {fb_id: id,
                    bytesLoaded: bytesLoaded, bytesTotal: bytesTotal});
            }
            if (!_jsurlstream)
                return;
            // XXX marka/bahaa: jsurlstream.load() generates req_id, it can serve few fetch_bin quries
	    // but one jsurlstream can support one URL, so if jsurlstream.load() called 2nd time we dont
	    // expect answers for previous load(). Usually, it should be handled by JS-part - if one JS req
	    // finished and provided data then all other parallel reqs should be cancelled.
	    // One exception - rate requests, they should continue even when jsurlstream would receive full data
	    if (_jsurlstream.req_id!=_jsurlstream_id)
                return void (!is_rate && ZErr.notice("req", id, "switched"));
            _jsurlstream.on_fragment_data({stream: this});
        }

        private function onstatus(e:HTTPStatusEvent):void{
            JSAPI.postMessage('holaflash.streamHttpStatus',
                {fb_id: id, status: e.status});
        }

        private function oncomplete(e:Event):void{
            JSAPI.postMessage('holaflash.streamComplete',
                {fb_id: id, bytesTotal: bytesTotal});
        }

        private function onerror(e:ErrorEvent):void{
            JSAPI.postMessage('holaflash.streamError', {fb_id: id});
            _delete();
        }
    }
}
