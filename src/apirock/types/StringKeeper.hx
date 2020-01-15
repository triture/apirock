package apirock.types;

import haxe.ds.StringMap;

abstract StringKeeper(String) from String {

    static private var KEEPER_MAP:StringMap<String> = new StringMap<String>();

    public function new(value:String) this = value;

    @:to
    inline public function toString():String return StringKeeper.parse(this);

    @:to
    inline private function toDynamic():Dynamic return StringKeeper.parse(this);

    inline public function getStringUnparsed():String return this;

    @:op(A + B)
    static public function stringkeeper_plus_string(a:StringKeeper, b:String):String {
        return a.toString() + new StringKeeper(b).toString();
    }

    @:op(A + B)
    static public function string_plus_stringkeeper(a:String, b:StringKeeper):String {
        return new StringKeeper(a).toString() + b.toString();
    }
    
    static public function parse(value:String):String {
        var map:StringMap<String> = KEEPER_MAP;
        var result = value;

        for (key in map.keys()) result = result.split('#${key}').join(map.get(key));

        try {
            map = Sys.environment();
            if (map != null) for (key in map.keys()) {
                result = result.split('#${key}').join(map.get(key));
            }
        } catch(e:Dynamic) {}

        return result;
    }

    static public function addData(key:String, value:String):Void {
        if (StringTools.startsWith(key, '#')) key = key.substr(1);
        KEEPER_MAP.set(key, value);
    }

    static public function getData(key:String):String {
        if (StringTools.startsWith(key, '#')) key = key.substr(1);
        if (KEEPER_MAP.exists(key)) return KEEPER_MAP.get(key);
        else if (Sys.environment().exists(key)) return Sys.environment().get('key');
        return '';
    }
    
    static public function clear():Void KEEPER_MAP = new StringMap<String>();
}
