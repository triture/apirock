package apirock.strof;

private typedef StrofValue = {
    var type:StrofType;
    var field:String;

    var canBeNull:Bool;
    @:optional var valuesType:StrofType;
    @:optional var valuesCanBeNull:Bool;
    @:optional var strofValidator:Class<Strof>;
}

class Strof {

    private var validations:Array<StrofValue> = [];

    private var rootStrof:StrofValue;

    public function new() {
        this.setRootType(StrofType.STROF);
    }

    private function setRootType(type:StrofType):Void {
        this.rootStrof = {
            type : type,
            field : "",
            canBeNull : false,
            valuesType : StrofType.STROF,
            strofValidator : Type.getClass(this),
            valuesCanBeNull : false
        }
    }

    private function validateValue(value:Dynamic, validation:StrofValue, parentField:String):Array<String> {
        var errors:Array<String> = [];
        var fieldPath:String = parentField + (parentField == "" || validation.field == "" ? "" : ".") + validation.field;

        if (value == null && !validation.canBeNull) errors.push('Field "${fieldPath}" cannot be NULL');
        else if (value != null) {

            switch (validation.type) {
                case StrofType.NUMBER : if (!Std.is(value, Int) && !Std.is(value, Float)) errors.push('Field "${fieldPath}" must be NUMBER');
                case StrofType.STRING : if (!Std.is(value, String)) errors.push('Field "${fieldPath}" must be STRING');
                case StrofType.BOOL : if (!Std.is(value, Bool)) errors.push('Field "${fieldPath}" must be BOOL');
                case StrofType.ARRAY : {

                    if (Std.is(value, Array)) {

                        var values:Array<Dynamic> = value;
                        var indexCount:Int = -1;

                        for (itemValue in values) {
                            indexCount++;

                            var fieldArrayPath:String = fieldPath + (fieldPath == "" ? "Array" : "") + '[${indexCount}]';

                            if (itemValue == null && validation.valuesCanBeNull) errors.push('Field "${fieldArrayPath}" cannot be NULL')
                            else {

                                //var fieldArrayPathWithField:String = fieldArrayPath + "." + validation.field;

                                errors = errors.concat(
                                    this.validateValue(
                                        itemValue,
                                        {
                                            type : validation.valuesType,
                                            field : "",
                                            canBeNull : validation.valuesCanBeNull,
                                            strofValidator : validation.strofValidator,
                                            valuesCanBeNull : false
                                        },
                                        fieldArrayPath
                                    )
                                );

                            }
                        }
                    } else {

                        errors.push('Field "${fieldPath}" is not ARRAY');

                    }
                }
                case StrofType.STROF : {
                    try {
                        var strof:Strof = Type.createInstance(validation.strofValidator, []);
                        strof.validateStrofObject(value, fieldPath);
                    } catch (e:Dynamic) {
                        errors = errors.concat(e);
                    }
                }
            }
        }

        return errors;
    }

    public function validate(data:Dynamic):Void {

        var errors:Array<String> = [];

        errors = errors.concat(
            this.validateValue(
                data,
                this.rootStrof,
                ""
            )
        );

        if (errors.length > 0) {
            errors.push("DATA RECEIVED: " + haxe.Json.stringify(data));
            throw errors;
        }
    }

    private function validateStrofObject(data:Dynamic, parentField:String):Void {

        var errors:Array<String> = [];

        if (!Reflect.isObject(data)) {
            errors.push("DATA Must be an Object");
        } else {

            for (strofValue in this.validations) {

                if (Reflect.hasField(data, strofValue.field)) {

                    var value:Dynamic = Reflect.field(data, strofValue.field);

                    errors = errors.concat(this.validateValue(value, strofValue, parentField));

                } else {
                    var fieldPath:String = parentField + (parentField == "" ? "" : ".") + strofValue.field;

                    if (!strofValue.canBeNull) errors.push('Field "${fieldPath}" cannot be null');
                }
            }
        }

        if (errors.length > 0) {
//            errors.push("DATA RECEIVED: " + haxe.Json.stringify(data));
            throw errors;
        }
    }

    public function validateNumber(field:String, canBeNull:Bool = false):Strof {
        this.validations.push(
            {
                type : StrofType.NUMBER,
                field : field,
                canBeNull : canBeNull
            }
        );
        return this;
    }

    public function validateString(field:String, canBeNull:Bool = false):Strof {
        this.validations.push(
            {
                type : StrofType.STRING,
                field : field,
                canBeNull : canBeNull
            }
        );
        return this;
    }

    public function validateBool(field:String, canBeNull:Bool = false):Strof {
        this.validations.push(
            {
                type : StrofType.BOOL,
                field : field,
                canBeNull : canBeNull
            }
        );
        return this;
    }

    public function validateArray(field:String, valuesType:StrofType, ?strofValidator:Class<Strof>, valuesCanBeNull:Bool = false, canBeNull:Bool = false):Strof {
        if (valuesType == StrofType.STROF && strofValidator == null) {
            throw "Informe um strofValidator para o tipo STROF";
        }

        this.validations.push(
            {
                type : StrofType.ARRAY,
                field : field,
                canBeNull : canBeNull,

                valuesType : valuesType,
                valuesCanBeNull : valuesCanBeNull,
                strofValidator : strofValidator
            }
        );
        return this;
    }

    public function validateObject(field:String, strofValidator:Class<Strof>, canBeNull:Bool = false):Strof {
        this.validations.push(
            {
                type : StrofType.STROF,
                field : field,
                canBeNull : canBeNull,
                strofValidator : strofValidator
            }
        );
        return this;
    }
}
