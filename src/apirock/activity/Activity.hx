package apirock.activity;

import apirock.ApiRock;
import apirock.extensors.Keeper;
import apirock.helper.ApiRockOut;

class Activity {

    private var apirock:ApiRock;

    @:allow(apirock.extensors.Keeper)
    private var keepList:Array<Keeper> = [];

    public function new(apirock:ApiRock) {
        this.apirock = apirock;
    }

    private function printCatchError(e:Dynamic):Void {
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

    public function then():ApiRock return this.apirock;

    @:allow(apirock.ApiRock)
    private function execute(index:Int):Void throw "Must override this method";


}
