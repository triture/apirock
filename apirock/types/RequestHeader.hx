package apirock.types;

class RequestHeader {

    public var header:StringKeeper;
    public var value:StringKeeper;

    public function new(header:StringKeeper, value:StringKeeper) {
        this.header = header;
        this.value = value;
    }

    public function toString():String {
        return '${this.header}: ${this.value}';
    }
}
