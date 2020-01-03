package apirock.activity;

@:enum
abstract WaitActivityMeasure(String) to String from String {
    var MINUTES = "minutes";
    var SECONDS = "seconds";
    var HOURS = "hours";
}
