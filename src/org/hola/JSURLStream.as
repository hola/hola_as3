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

    public dynamic class JSURLStream extends URLStream {
        private static var js_api_inited : Boolean = false;
        private static var req_count : Number = 0;
        private static var reqs : Object = {};
        private var _connected : Boolean;
        private var _resource : ByteArray = new ByteArray();
        private var _hola_managed : Boolean = false;
        private var _req_id : String;

        public function JSURLStream(){
            _hola_managed = HSettings.hls_mode && ZExternalInterface.avail();
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
                hola_onFragmentData);
            js_api_inited = true;
        }

        protected function _trigger(cb : String, data : Object) : void {
            if (!_hola_managed)
                return ZErr.log('invalid trigger'); // XXX arik: ZErr.throw
            ExternalInterface.call('window.hola_'+cb,
                {objectID: ExternalInterface.objectID, data: data});
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
            if (_hola_managed && reqs[_req_id])
            {
                _delete();
                _trigger('abortFragment', {req_id: _req_id});
            }
            if (super.connected)
                super.close();
            _connected = false;
        }

        override public function load(request : URLRequest) : void {
            if (_hola_managed && reqs[_req_id])
            {
                _delete();
                _trigger('abortFragment', {req_id: _req_id});
            }
            _hola_managed = HSettings.hls_mode && ZExternalInterface.avail();
            req_count++;
            _req_id = 'req'+req_count;
            if (!_hola_managed)
                return super.load(request);
            reqs[_req_id] = this;
            _resource = new ByteArray();
            _trigger('requestFragment', {url: request.url, req_id: _req_id});
            this.dispatchEvent(new Event(Event.OPEN));
        }

        private function onopen(e : Event) : void { _connected = true; }

        private function append_data(data : IDataInput, total : uint) : void {
            var prev : uint = _resource.position;
            data.readBytes(_resource, _resource.length);
            _resource.position = prev;
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false,
                false, _resource.length, total||_resource.length));
        }

        private function on_fragment_data(o : Object) : void {
            if (o.error)
                return resourceLoadingError();
            if (o.fetchBinReqId)
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
            var fetchBinReq : Object;
            if (!(fetchBinReq = FetchBin.req_list[o.fetchBinReqId]))
                throw new Error('fetchBinReqId not found '+o.fetchBinReqId);
            var stream : URLStream = fetchBinReq.stream;
            if (stream.bytesAvailable)
                append_data(stream, fetchBinReq.bytesTotal);
            resourceLoadingSuccess();
            FetchBin.hola_fetchBinRemove(o.fetchBinReqId);
        }

        private static function hola_onFragmentData(o : Object) : void {
            var stream : JSURLStream;
            try {
                if (!(stream = reqs[o.req_id]))
                    return ZErr.log('req_id not found '+o.req_id);
                stream.on_fragment_data(o);
            } catch(err : Error){
                ZErr.log('Error in hola_onFragmentData', ''+err,
                    ''+err.getStackTrace());
                if (stream)
                    stream.resourceLoadingError();
                throw err;
            }
        }

        private function _delete() : void {
            delete reqs[_req_id];
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
