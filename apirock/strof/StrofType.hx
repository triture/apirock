package apirock.strof;

@:enum
abstract StrofType(Int) {
    var NUMBER = 0;
    var STRING = 1;
    var BOOL = 2;
    var ARRAY = 3;
    var STROF = 4;
}
