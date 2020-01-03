package apirock.types;

import haxe.ds.StringMap;
import apirock.extensors.Keeper;

@:access(apirock.extensors.Keeper)
abstract StringKeeper(String) from String {

    @:to
    inline public function toString():String return StringKeeper.parse(this);
    
    static public function parse(value:String):String {
        var map:StringMap<String> = Keeper.keeperMap;
        var result = value;

        for (key in map.keys()) result = result.split("#" + key).join(map.get(key));

        return result;
    }

}
