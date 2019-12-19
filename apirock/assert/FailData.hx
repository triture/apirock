package apirock.assert;

class FailData {

    static public function get(data:Dynamic, field:String, value:Dynamic = null):Dynamic {
        var clone:Dynamic = haxe.Json.parse(haxe.Json.stringify(data));

        Reflect.setField(clone, field, value);

        return clone;
    }

}
