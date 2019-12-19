package apirock.extensors;

import apirock.helper.ApiRockOut;
import haxe.ds.StringMap;
import apirock.activity.Activity;

class Keeper {

    static public var keeperMap:StringMap<String> = new StringMap<String>();

    private var isData:Bool = true;
    private var property:String;
    private var key:String;

    private var activity:Activity;

    public function new(activity:Activity) {
        this.activity = activity;
    }

    @:allow(apirock.activity.Activity)
    private function runKeeper(data:Dynamic):Void {

        var tree:Array<String> = this.property.split(".");
        var dataFound:Dynamic = data;

        try {

            for (field in tree) {

                // is numeric field ?
                if (Std.parseInt(field) != null && Std.is(dataFound, Array)) {
                    // espera que o valor atual seja um array

                    var index:Int = Std.parseInt(field);
                    var dataFoundArray:Array<Dynamic> = cast(dataFound, Array<Dynamic>);

                    dataFound = dataFoundArray[index];

                } else {
                    dataFound = Reflect.field(dataFound, field);
                }
            }

            if (dataFound == null) throw "NULL VALUE";

        } catch (e:Dynamic) {

            ApiRockOut.print("");
            ApiRockOut.print(" KEEPER ERROR : ");
            ApiRockOut.print(" Cannot found " + this.property + " property");
            ApiRockOut.print(" " + haxe.Json.stringify(data));
            ApiRockOut.print(" ");

            Sys.exit(1);

        }

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
        this.property = header;
        this.key = key;
        this.activity.keepList.push(this);

        return new Keeper(this.activity);
    }

    public function then():APIRock return this.activity.then();

    static public function addData(key:String, value:String):Void {
        #if apidebug
        ApiRockOut.print(" ");
        ApiRockOut.print(" KEEPER: " + key + " " + value);
        ApiRockOut.print(" ");
        #end

        keeperMap.set(key, value);
    }

    static public function getData(key:String):String return keeperMap.exists(key) ? keeperMap.get(key) : "";

}
