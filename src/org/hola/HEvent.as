package org.hola
{
    import flash.events.Event;

    public class HEvent extends Event
    {
        public static const WORKER_MESSAGE : String = "HEvent.WORKER_MESSAGE";
        private var _data : *;

        public function HEvent(type : String, data : *,
            bubbles : Boolean = false, cancelable : Boolean = false) : void
        {
            super(type, bubbles, cancelable);
            _data = data;
        }

        public function get data() : * {
            return _data;
        }

        override public function clone() : Event {
            return new HEvent(type, _data, bubbles, cancelable);
        }

        override public function toString() : String
        {
            return formatToString("HEvent", "type", "data", "bubbles",
                "cancelable", "eventPhase");
        }
    }
}
