package apirock.types;

import haxe.ds.StringMap;
import apirock.extensors.Keeper;

abstract StringKeeper(String) from String {

    @:to
    public function toString():String {
        var map:StringMap<String> = Keeper.keeperMap;
        var result = this;

        for (key in map.keys()) result = result.split("#" + key).join(map.get(key));

        return result;
    }

}
