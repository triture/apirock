package apirock.extensors;

import apirock.helper.ApiRockOut;
import haxe.ds.StringMap;
import apirock.activity.Activity;

class Keeper {
    
    static private var keeperMap:StringMap<String> = new StringMap<String>();

    private var isData:Bool = true;
    private var property:String;
    private var key:String;

    private var activity:Activity;

    public function new(activity:Activity) {
        this.activity = activity;
    }

    @:allow(apirock.activity.Activity)
    private function runKeeper(data:Dynamic, responseHeaders:Map<String, String>):Void {

        var dataFound:Dynamic = data;

        if (this.isData) {
            // get data from result data

            var tree:Array<String> = this.property.split(".");

            try {
                if (data == null) throw "Data is null";

                for (field in tree) {

                    // if this is a numeric field, array value is expected
                    if (Std.parseInt(field) != null && Std.is(dataFound, Array)) {

                        var index:Int = Std.parseInt(field);
                        var dataFoundArray:Array<Dynamic> = cast(dataFound, Array<Dynamic>);

                        dataFound = dataFoundArray[index];

                    } else {
                        dataFound = Reflect.field(dataFound, field);
                    }
                }

                if (dataFound == null) {
                    // TODO: what to do in this situation??
                    // maybe throw "NULL VALUE"
                    // or set value as empty string
                    dataFound = "";
                }

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

        Keeper.addData(this.key, Std.string(dataFound));
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

    static public function addData(key:String, value:String):Void keeperMap.set(key, value);
    static public function getData(key:String):String return keeperMap.exists(key) ? keeperMap.get(key) : "";

}
