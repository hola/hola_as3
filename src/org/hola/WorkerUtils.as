package org.hola {
    CONFIG::HAVE_WORKER {
    import flash.system.Worker;
    import flash.system.WorkerDomain;
    import flash.system.MessageChannel;
    }
    import flash.events.EventDispatcher
    import flash.events.Event;
    import org.hola.HEvent;

    public class WorkerUtils {
        private static var _dispatcher : EventDispatcher =
            new EventDispatcher();
        CONFIG::HAVE_WORKER {
        private static var _ochan : MessageChannel;
        private static var _ichan : MessageChannel;
        private static var _worker : Worker;

        public static function get worker() : Worker {
            return _worker;
        }
        }

        public static function start_worker(WorkerSWF : Class) : void {
            CONFIG::HAVE_WORKER {
            if (_worker || !Worker.isSupported)
                return;
            _worker = WorkerDomain.current.createWorker(new WorkerSWF());
            _ochan = Worker.current.createMessageChannel(_worker);
            _ichan = _worker.createMessageChannel(Worker.current);
            _ichan.addEventListener(Event.CHANNEL_MESSAGE, onmsg);
            _worker.setSharedProperty("m2w", _ochan);
            _worker.setSharedProperty("w2m", _ichan);
            _worker.start();
            }
        }

        private static function onmsg(e : Event) : void {
            var msg : * = recv();
            _dispatcher.dispatchEvent(new HEvent(HEvent.WORKER_MESSAGE, msg));
        }

        public static function send(msg : *) : void {
            CONFIG::HAVE_WORKER {
            if (!_ochan)
                throw new Error("worker not running");
            _ochan.send(msg);
            }
        }

        public static function recv() : * {
            CONFIG::HAVE_WORKER {
            if (!_ichan)
                throw new Error("worker not running");
            return _ichan.receive();
            }
        }

        public static function addEventListener(...args) : void
        {
            _dispatcher.addEventListener.apply(_dispatcher, args);
        }

        public static function removeEventListener(...args) : void
        {
            _dispatcher.removeEventListener.apply(_dispatcher, args);
        }
    }
}
