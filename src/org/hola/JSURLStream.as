/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package org.hola {
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.net.URLRequest;
    import flash.net.URLStream;
    import flash.utils.ByteArray;
    import flash.utils.IDataInput;

    public class JSURLStream extends URLStream {
        private static var js_api_inited : Boolean = false;
        private static var req_count : Number = 0;
        private static var reqs : Object = {};
        private var _connected : Boolean;
        private var _resource : ByteArray = new ByteArray();
        private var _hola_managed : Boolean = false;
        public var req_id : String;

        public function JSURLStream(){
            _hola_managed = (HSettings.gets('mode')!='native') && ZExternalInterface.avail();
            addEventListener(Event.OPEN, onopen);
            super();
            if (!ZExternalInterface.avail() || js_api_inited)
                return;
            /* XXX arik: setting this to true will pass js exceptions to
             * as3 and as3 exceptions to js. this may break current customer
             * code
             ExternalInterface.marshallExceptions = true;
             */
            ExternalInterface.addCallback('hola_onFragmentData',
                onFragmentData);
            js_api_inited = true;
        }

        protected function _trigger(cb : String, data : Object) : void {
            if (!_hola_managed)
                return ZErr.err('invalid trigger'); // XXX arik: ZErr.throw
            JSAPI.postMessage(cb, data);
        }

        override public function get connected() : Boolean {
            if (!_hola_managed)
                return super.connected;
            return _connected;
        }

        override public function get bytesAvailable() : uint {
            if (!_hola_managed)
                return super.bytesAvailable;
            return _resource.bytesAvailable;
        }

        override public function readByte() : int {
            if (!_hola_managed)
                return super.readByte();
            return _resource.readByte();
        }

        override public function readUnsignedShort() : uint {
            if (!_hola_managed)
                return super.readUnsignedShort();
            return _resource.readUnsignedShort();
        }

        override public function readBytes(bytes : ByteArray,
            offset : uint = 0, length : uint = 0) : void
        {
            if (!_hola_managed)
                return super.readBytes(bytes, offset, length);
            _resource.readBytes(bytes, offset, length);
        }

        override public function close() : void {
            if (_hola_managed && get(req_id))
            {
                _delete();
                _trigger('hola.abortFragment', {req_id: req_id});
            }
            if (super.connected)
                super.close();
            _connected = false;
        }

        override public function load(request : URLRequest) : void {
            if (_hola_managed && get(req_id))
            {
                _delete();
                _trigger('hola.abortFragment', {req_id: req_id});
            }
            _hola_managed = (HSettings.gets('mode')!='native') && ZExternalInterface.avail();
            req_count++;
            req_id = 'req'+req_count;
            if (!_hola_managed)
                return super.load(request);
            reqs[req_id] = this;
            _resource = new ByteArray();
            _trigger('hola.requestFragment', {url: request.url, req_id: req_id, context: request.data});
            this.dispatchEvent(new Event(Event.OPEN));
        }

        private function onopen(e : Event) : void { _connected = true; }

        private function append_data(data : IDataInput, total : uint) : uint {
            var prev_pos : uint = _resource.position;
            var prev_len : uint = _resource.length;
            data.readBytes(_resource, _resource.length);
            _resource.position = prev_pos;
            var r : uint = _resource.length-prev_len;
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false,
                false, _resource.length, total||_resource.length));
            return r;
        }

        public function on_fragment_data(o : Object) : void {
            if (o.error)
                return resourceLoadingError();
            if (o.fetchBinReqId || o.stream)
                return fetch_bin(o);
            if (o.data)
            {
                var data : ByteArray = Base64.decode_str(o.data);
                data.position = 0;
                append_data(data, o.total);
            }
            // XXX arik: dispatch httpStatus/httpResponseStatus
            if (o.status)
                resourceLoadingSuccess();
        }

        private function fetch_bin(o : Object) : void {
            var stream : FetchBin = o.stream, n : int;
            if (!stream && !(stream = FetchBin.get(o.fetchBinReqId)))
                throw new Error('fetchBinReqId not found '+o.fetchBinReqId);
            if (_resource.length<stream.bytesLoaded) // stream has new data
            {
                if ((n = _resource.length-stream.bytesRead)>0)
                {
                    // dispose of data we already have
                    var t : ByteArray = new ByteArray();
                    stream.readBytes(t, 0, n);
                    stream.read_ack(n);
                }
                // read new data
                stream.read_ack(append_data(stream, stream.bytesTotal));
            }
            if (_resource.length<stream.bytesTotal) // more data pending
                return;
            if (!o.fetchBinReqId) // cleanup only when called by JS
                return;
            resourceLoadingSuccess();
            FetchBin.remove(o.fetchBinReqId);
        }

        private static function onFragmentData(o : Object) : void {
            var stream : JSURLStream;
            try {
                if (!(stream = get(o.req_id)))
                    return ZErr.notice('req_id not found '+o.req_id);
                stream.on_fragment_data(o);
            } catch(err : Error){
                ZErr.err('Error in onFragmentData', ''+err,
                    ''+err.getStackTrace());
                if (stream)
                    stream.resourceLoadingError();
                throw err;
            }
        }

        public static function get(id:String):JSURLStream{
            return reqs[id];
        }

        private function _delete() : void {
            delete reqs[req_id];
        }

        protected function resourceLoadingError() : void {
            _delete();
            dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
        }

        protected function resourceLoadingSuccess() : void {
            _delete();
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }
}
