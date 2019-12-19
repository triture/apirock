package apirock.activity.wait;

@:enum
abstract WaitTimeMeasure(String) to String from String {
    var MINUTES = "minutes";
    var SECONDS = "seconds";
    var HOURS = "hours";
}
