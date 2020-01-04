package apirock.types;

import haxe.ds.StringMap;

typedef RequestData = {
    var url:String;
    var method:String;
    var data:String;
    var headers:StringMap<String>;
}
