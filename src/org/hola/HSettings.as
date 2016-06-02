package org.hola {
    import flash.external.ExternalInterface;

    public class HSettings {
        private static var _inited: Boolean = false;
	// defaults
	private static var _dict: Object = {player_id: 1, mode: 'native'};
	private static const _formats: Object = {
	    player_id: 'number',
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

        private static function settings(s: Object): Object
	{
            for (var k: String in s)
            {
	        switch (_formats[k])
		{
		case 'number': _dict[k] = +s[k]; break;
		case 'string': _dict[k] = ''+s[k]; break;
		}
            }
	    return _dict;
        }
    }
}
