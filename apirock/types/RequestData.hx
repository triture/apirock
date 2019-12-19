package apirock.types;

typedef RequestData = {
    var url:StringKeeper;
    var method:StringKeeper;
    var data:String;
    var headers:Array<RequestHeader>;
}
