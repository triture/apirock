package apirock.activity;

import apirock.ApiRock;
import apirock.extensors.Keeper;
import apirock.helper.ApiRockOut;

class Activity {

    public var silent:Bool;
    private var apirock:ApiRock;

    @:allow(apirock.extensors.Keeper)
    private var keepList:Array<Keeper> = [];

    public function new(apirock:ApiRock, silent:Bool = false) {
        this.silent = silent;
        this.apirock = apirock;
    }

    private function printCatchError(e:Dynamic):Void {
        this.silent = false;

        if (Std.isOfType(e, Array)) {

            ApiRockOut.print("");
            ApiRockOut.print("ERROR : ");
            ApiRockOut.print(e.join("\n"));
            ApiRockOut.print("");

        } else {
            ApiRockOut.print("");
            ApiRockOut.print("ERROR : ");
            ApiRockOut.print(Std.string(e));
            ApiRockOut.print("");
        }

        Sys.exit(1);
    }

    private function print(info:String):Void if (!this.silent) ApiRockOut.print(info);
    private function printBox(text:String):Void if (!this.silent) ApiRockOut.printBox(text);
    private function printWithTab(text:String, tabs:Int):Void if (!this.silent) ApiRockOut.printWithTab(text, tabs);
    private function printIndex(index:String, text:String):Void if (!this.silent) ApiRockOut.printIndex(index, text);
    private function printList(data:Array<String>, tabs:Int):Void if (!this.silent) ApiRockOut.printList(data, tabs);

    public function then():ApiRock return this.apirock;

    @:allow(apirock.ApiRock)
    private function execute(index:Int):Void throw "Must override this method";


}
