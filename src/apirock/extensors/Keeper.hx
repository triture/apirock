package apirock.extensors;

import apirock.types.StringKeeper;
import apirock.ApiRock;
import apirock.helper.ApiRockOut;
import haxe.ds.StringMap;
import apirock.activity.Activity;

@:access(apirock.types.StringKeeper)
class Keeper {
    
    static private var keeperMap:StringMap<String> = new StringMap<String>();

    private var isData:Bool = true;
    private var property:String;
    private var key:String;

    private var activity:Activity;

    public function new(activity:Activity) {
        this.activity = activity;
    }

    private function drill(fields:Array<String>, data:Dynamic):Dynamic {
        if (fields == null || fields.length == 0 || data == null) return data;

        var field:String = fields.shift();

        while (field == '') field = fields.shift();

        // is asking for array ?
        var regex:EReg = new EReg('\\[\\d+\\]$', '');
        
        if (regex.match(field)) {

            var matched:String = regex.matched(0);
            var field:String = regex.matchedLeft();

            if (Reflect.hasField(data, field) && Std.is(Reflect.field(data, field), Array)) {
                var index:Int = Std.parseInt(matched.substring(1, matched.length-1));
                var arrData:Array<Dynamic> = Reflect.field(data, field);

                if (arrData.length > index) return drill(fields, arrData[index]);
            }

        } else if (Reflect.hasField(data, field)) return drill(fields, Reflect.field(data, field));
        
        return null;
    }


    @:allow(apirock.activity.Activity)
    private function runKeeper(data:Dynamic, responseHeaders:Map<String, String>):Void {

        var dataFound:Dynamic = data;

        if (this.isData) {
            // get data from result data
            try {
                
                dataFound = this.drill(this.property.split("."), data);

                if (dataFound == null) throw "Data is null";

            } catch (e:Dynamic) {

                ApiRockOut.printWithTab('- Error! Cannot found ${this.property} property', 3);
                ApiRockOut.printBox(" KEEPER ERROR : ");

                Sys.exit(1);

            }
        } else {
            // get data from headers

            if (responseHeaders == null || !responseHeaders.exists(this.property)) {
                ApiRockOut.printWithTab('- Error! Cannot found ${this.property} header', 3);
                ApiRockOut.printBox(" KEEPER ERROR : ");

                Sys.exit(1);
            } else {
                dataFound = responseHeaders.get(this.property);
            }
        }

        ApiRockOut.printWithTab('- Keeping ${this.property} in memory', 3);

        StringKeeper.addData(this.key, Std.string(dataFound));
    }

    public function keepingData(property:String, key:String):Keeper {
        this.isData = true;
        this.property = property;
        this.key = key;
        this.activity.keepList.push(this);

        return new Keeper(this.activity);
    }

    public function keepingHeader(header:String, key:String):Keeper {
        this.isData = false;
        this.property = header.toLowerCase();
        this.key = key;
        this.activity.keepList.push(this);

        return new Keeper(this.activity);
    }

    public function then():ApiRock return this.activity.then();

}
