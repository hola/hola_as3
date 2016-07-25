package org.hola {
    import flash.external.ExternalInterface;

    public class HSettings
    {
        private static var _inited: Boolean = false;
	private static var _listeners: Object = {};
	// defaults
	private static var _dict: Object = {
	    player_id: ExternalInterface.objectID, mode: 'native'};
	// mode can be: ['native', 'adaptive', 'progressive', 'hola_adaptive']
	private static const _formats: Object = {
	    player_id: 'string',
	    mode: 'string'
	};

        public static function init(): void
	{
            if (_inited || !ZExternalInterface.avail())
                return;
            _inited = true;
            ExternalInterface.addCallback("hola_settings", settings);
        }

        public static function gets(name: String): *
	{
	    return _dict[name];
	}

	public static function subscribe(name: String, cb: Function): void
	{
	    _listeners[name] = _listeners[name]||[];
	    _listeners[name].push(cb);
	}

	public static function unsubscribe(name: String, cb: Function): void
	{
	    var arr: Array = _listeners[name];
	    if (!arr)
	        return;
	    for (var i: int = 0; i<arr.length; i++)
	    {
	        if (arr[i]!==cb)
		    continue;
	        arr.splice(i, 1);
		i--;
            }
	}

        private static function settings(s: Object): Object
	{
            for (var k: String in s)
            {
	        switch (_formats[k])
		{
		case 'number': _dict[k] = +s[k]; break;
		case 'string': _dict[k] = ''+s[k]; break;
		}
		var arr: Array = _listeners[k];
		if (!arr)
		    continue;
		for each (var cb: Function in arr)
		    cb(_dict[k], k);
            }
	    return _dict;
        }
    }
}
