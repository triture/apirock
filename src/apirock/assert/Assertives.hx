package apirock.assert;

import apirock.activity.Activity;

class Assertives {

    private var assertive:Dynamic;
    private var errors:Array<String> = [];
    private var map:Array<String> = [];

    public function new(activity:Activity) {
        activity.assertive = this;
    }

    public function getErrors():Array<String> return this.errors.copy();

    public function setAssertive(value:Dynamic) this.assertive = value;

    public function compare(data:Dynamic):Bool {
        this.errors = [];
        this.map = [];
        return this.compareValues(this.assertive, data);
    }

    private function compareTypes(a:Dynamic, b:Dynamic):Bool {
        if (a == null && b == null) return true;
        else if (Std.is(a, String) && Std.is(b, String)) return true;
        else if (Std.is(a, Float) && Std.is(b, Float)) return true;
        else if (Std.is(a, Int) && Std.is(b, Int)) return true;
        else if (Std.is(a, Bool) && Std.is(b, Bool)) return true;
        else if (Std.is(a, Array) && Std.is(b, Array)) return true;
        else if (Reflect.isObject(a) && Reflect.isObject(b)) return true;
        else {

            if (a == null || b == null) {
                this.addErrorValue(a, b);
                return false;

            } else {

                if (this.map.length > 0) this.errors.push("Wrong type for " + this.map.join("."));
                else this.errors.push("Values are not same type");

                return false;
            }
        }
    }

    private function compareValues(a:Dynamic, b:Dynamic):Bool {

        if (this.compareTypes(a, b)) {

            if (Std.is(a, String)) return this.compareStrings(a, b);
            else if (Std.is(a, Float)) return this.compareFloats(a, b);
            else if (Std.is(a, Int)) return this.compareInts(a, b);
            else if (Std.is(a, Bool)) return this.compareBools(a, b);
            else if (Std.is(a, Array)) return this.compareArrays(a, b);
            else if (Reflect.isObject(a)) return this.compareObjects(a, b);
            else {

                this.errors.push("Unable to identify types");

                return false;
            }

        } else return false;
    }

    private function addErrorValue(expected:Dynamic, gets:Dynamic):Void {
        var error:String = "";
        error += "Wrong value";

        if (this.map.length > 0) error += " for " + this.map.join(".");

        error += ": Expects '" + Std.string(expected) + "' and Gets '" + Std.string(gets) + "'";

        this.errors.push(error);
    }

    private function compareStrings(a:String, b:String):Bool {
        if (a == b) return true;
        else {
            this.addErrorValue(a, b);
            return false;
        }
    }
    private function compareInts(a:Int, b:Int):Bool {
        if (a == b) return true;
        else {
            this.addErrorValue(a, b);
            return false;
        }
    }
    private function compareBools(a:Bool, b:Bool):Bool {
        if (a == b) return true;
        else {
            this.addErrorValue(a, b);
            return false;
        }
    }
    private function compareFloats(a:Float, b:Float):Bool {
        if (Math.abs(a - b) < 0.0001) return true;
        else {
            this.addErrorValue(a, b);
            return false;
        }
    }

    private function compareArrays(a:Array<Dynamic>, b:Array<Dynamic>):Bool {
        if (a.length == b.length) {

            for (i in 0 ... a.length) {
                this.map.push("[" + i + "]");
                if (!this.compareValues(a[i], b[i])) return false;
                this.map.pop();
            }

            return true;
        } else {
            this.errors.push("Arrays have wrong length at " + this.map.join("."));
            return false;
        }
    }

    private function compareObjects(a:Dynamic, b:Dynamic):Bool {
        var fieldsA:Array<String> = Reflect.fields(a);
        var fieldsB:Array<String> = Reflect.fields(b);

        var hasErrors:Bool = false;

        for (field in fieldsA) {
            this.map.push(field);

            if (fieldsB.indexOf(field) == -1) {
                this.errors.push("Field " + this.map.join(".") + " not found");
                hasErrors = true;
            } else {

                var aValue:Dynamic = Reflect.field(a, field);
                var bValue:Dynamic = Reflect.field(b, field);

                if (!this.compareValues(aValue, bValue)) {
                    hasErrors = true;
                }

            }

            this.map.pop();
        }

        return !hasErrors;
    }
}
