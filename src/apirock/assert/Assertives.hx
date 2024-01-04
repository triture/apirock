package apirock.assert;

import apirock.types.StringKeeper;
import datetime.DateTime;
import anonstruct.AnonStruct;

@:access(anonstruct.AnonStruct)
@:access(anonstruct.AnonProp)
@:access(anonstruct.AnonPropDate)
@:access(anonstruct.AnonPropArray)
@:access(anonstruct.AnonPropObject)
@:access(anonstruct.AnonPropString)
@:access(anonstruct.AnonPropInt)
@:access(anonstruct.AnonPropFloat)
@:access(anonstruct.AnonPropBool)
class Assertives {

    private var assertive:Dynamic;
    private var errors:Array<String> = [];

    private var trackErrors:Bool = true;

    public function new() {
        
    }

    private function addError(message:String):Void if (trackErrors) this.errors.push(message);

    inline private function isString(value:Dynamic):Bool return new AnonStruct().valueString().validate_isString(value);
    inline private function isInt(value:Dynamic):Bool return new AnonStruct().valueInt().validate_isInt(value);
    inline private function isDate(value:Dynamic):Bool return new AnonStruct().valueDate().validate_isDateTime(value);
    inline private function isFloat(value:Dynamic):Bool return new AnonStruct().valueFloat().validate_isFloat(value);
    inline private function isBool(value:Dynamic):Bool return new AnonStruct().valueBool().validate_isBool(value);
    inline private function isArray(value:Dynamic):Bool return new AnonStruct().valueArray().validate_isArray(value);
    inline private function isObject(value:Dynamic):Bool return new AnonStruct().valueObject().validate_isObject(value);
    
    inline private function getArrayIndexRegex():EReg return new EReg('\\[\\d+\\]$', '');

    public function getErrors():Array<String> return this.errors.copy();
    
    public function setAssertive(value:Dynamic) this.assertive = value;
    public function getAssertive() return this.assertive;

    public function compare(data:Dynamic):Bool {
        this.errors = [];
        return this.compareValues(this.assertive, data);
    }

    // IMPORTANT : 
    // A = CHECK DATA (MUST HAVE THESE VALUES)
    // B = DATA RECEIVED
    // ALWAYS!

    private function compareValues(a:Dynamic, b:Dynamic, ?map:Array<String>):Bool {

        if (map == null) map = [];

        if (a == null && b == null) return true;
        else if (this.isString(a) && this.isString(b)) return this.compareStrings(a, b, map);
        else if (this.isInt(a) && this.isInt(b)) return this.compareInts(a, b, map);
        else if (this.isFloat(a) && this.isFloat(b)) return this.compareFloats(a, b);
        else if (this.isBool(a) && this.isBool(b)) return this.compareBools(a, b, map);
        else if (this.isArray(a) && this.isArray(b)) return this.compareArrays(a, b, map);
        else if (this.isDate(a) && this.isDate(b)) return this.compareDates(a, b, map);
        else if (this.isObject(a) && this.isObject(b)) return this.compareObjects(a, b, map);
        else {

            if (this.isObject(a) && this.isArray(b)) {
                // validate if is a special mode of validation (validate only some indexes)
                var correctMode:Bool = true;

                var newA:Dynamic = {};
                var newB:Dynamic = {};

                var fields:Array<String> = Reflect.fields(a);

                if (fields == null || fields.length == 0) correctMode = false;
                else {
                    for (field in fields) {
                        var ereg:EReg = this.getArrayIndexRegex();
                        
                        if (field == '[?]' || (ereg.match(field) && ereg.matchedLeft() == '')) {
                            Reflect.setField(newA, 'root${field}', Reflect.field(a, field));
                        } else {
                            correctMode = false;
                            break;
                        }
                    }
                }

                if (correctMode) {
                    Reflect.setField(newB, 'root', b);
                    return this.compareValues(newA, newB);
                }

            }

            if (map.length > 0) this.addError("Wrong type for " + map.join("."));
            else this.addError("Values are not same type");

            return false;
        }

    }

    private function addErrorValue(expected:Dynamic, gets:Dynamic, ?map:Array<String>):Void {

        if (map == null) map = [];

        var error:String = "";
        error += "Wrong value";

        if (map.length > 0) error += ' for \'${map.join(".")}\'';

        error += ": Expects '" + Std.string(expected) + "' and Gets '" + Std.string(gets) + "'";

        this.addError(error);
    }

    private function compareDates(a:Dynamic, b:Dynamic, ?map:Array<String>):Bool {
        var aString:String = '';
        var bString:String = '';

        if (Std.isOfType(a, Date)) {
            var aDate:DateTime = DateTime.fromDate(a);
            aString = aDate.toString();
        } else if (Std.isOfType(a, String)) {
            var aDate:DateTime = DateTime.fromString(a);
            aString = aDate.toString();
        } else if (Std.isOfType(a, Float)) {
            var aDate:DateTime = DateTime.fromTime(a);
            aString = aDate.toString();
        }

        if (Std.isOfType(b, Date)) {
            var bDate:DateTime = DateTime.fromDate(b);
            bString = bDate.toString();
        } else if (Std.isOfType(b, String)) {
            var bDate:DateTime = DateTime.fromString(b);
            bString = bDate.toString();
        } else if (Std.isOfType(b, Float)) {
            var bDate:DateTime = DateTime.fromTime(b);
            bString = bDate.toString();
        }

        if (aString == '' || bString == '') return false;
        else return aString == bString;
    }

    private function compareStrings(a:StringKeeper, b:StringKeeper, ?map:Array<String>):Bool {
        if (a.toString() == b.toString()) return true;
        else {
            this.addErrorValue(a.toString(), b.toString(), map);
            return false;
        }
    }

    private function compareInts(a:Int, b:Int, ?map:Array<String>):Bool {
        if (a == b) return true;
        else {
            this.addErrorValue(a, b, map);
            return false;
        }
    }

    private function compareBools(a:Bool, b:Bool, ?map:Array<String>):Bool {
        if (a == b) return true;
        else {
            this.addErrorValue(a, b, map);
            return false;
        }
    }

    private function compareFloats(a:Float, b:Float, ?map:Array<String>):Bool {
        if (Math.abs(a - b) < 0.0001) return true;
        else {
            this.addErrorValue(a, b, map);
            return false;
        }
    }

    private function compareArrays(a:Array<Dynamic>, b:Array<Dynamic>, ?map:Array<String>):Bool {

        if (map == null) map = [];

        if (a.length == b.length) {

            for (i in 0 ... a.length) {
                map.push("[" + i + "]");

                if (!this.compareValues(a[i], b[i], map)) return false;

                map.pop();
            }

            return true;

        } else {
            this.addError("Arrays have wrong length at " + map.join("."));
            return false;
        }
    }

    private function compareObjects(a:Dynamic, b:Dynamic, ?map:Array<String>):Bool {

        if (map == null) map = [];

        var fieldsA:Array<String> = Reflect.fields(a);

        var regex:EReg = this.getArrayIndexRegex();

        for (field in fieldsA) {
            map.push(field);

            if (Reflect.hasField(a, field) && Reflect.hasField(b, field)) {
                if (!this.compareValues(
                    Reflect.field(a, field),
                    Reflect.field(b, field),
                    map
                )) return false;
            } else if (StringTools.endsWith(field, '[?]')) {
                var arrField:String = field.substr(0, field.length-3);

                if (Reflect.hasField(b, arrField) && Std.isOfType(Reflect.field(b, arrField), Array)) {
                    var arrData:Array<Dynamic> = Reflect.field(b, arrField);
                    var currData:Dynamic = Reflect.field(a, field);

                    var itemFound:Bool = false;

                    var tempErrors:Array<String> = this.errors;
                    this.errors = [];

                    for (item in arrData) {
                        if (this.compareValues(currData, item, [])) {
                            itemFound = true;
                            break;
                        }
                    }

                    this.errors = tempErrors;

                    if (!itemFound) {
                        this.addError('${map.join(".")} doesnt have the value ${Std.string(currData)}');
                        return false;
                    }

                } else {
                    this.addError("Field '" + map.join(".") + "' not found");
                    return false;
                }

            } else if (regex.match(field)) {
                // the field A has array access?
                var matched:String = regex.matched(0);
                var arrField:String = regex.matchedLeft();

                if (Reflect.hasField(b, arrField) && Std.isOfType(Reflect.field(b, arrField), Array)) {
                    var index:Int = Std.parseInt(matched.substring(1, matched.length-1));
                    var arrData:Array<Dynamic> = Reflect.field(b, arrField);
                    
                    if (arrData.length > index && !this.compareValues(
                        Reflect.field(a, field), 
                        arrData[index]
                    )) return false;
                } else {
                    this.addError("Field '" + map.join(".") + "' not found");
                    return false;
                }
            } else {
                this.addError("Field '" + map.join(".") + "' not found");
                return false;
            }

            // if (fieldsB.indexOf(field) == -1) {
            //     this.errors.push("Field " + this.map.join(".") + " not found");
            //     return false;
            // } else {

            //     // var aValue:Dynamic = Reflect.field(a, field);
            //     // var bValue:Dynamic = Reflect.field(b, field);

            //     // if (!this.compareValues(aValue, bValue)) {
            //     //     hasErrors = true;
            //     // }

            // }

            map.pop();
        }

        return true;
    }
}
