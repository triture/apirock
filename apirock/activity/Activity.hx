package apirock.activity;

import apirock.assert.Assertives;
import apirock.extensors.Keeper;
import apirock.helper.ApiRockOut;

class Activity {

    private var apirock:APIRock;

    @:allow(apirock.extensors.Keeper)
    private var keepList:Array<Keeper> = [];

    @:allow(apirock.assert.Assertives)
    private var assertive:Assertives = null;

    public function new(apirock:APIRock) {
        this.apirock = apirock;
    }

    private function printCatchError(e:Dynamic):Void {
        if (Std.is(e, Array)) {

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

    public function then():APIRock return this.apirock;

    @:allow(apirock.APIRock)
    private function execute(index:Int):Void throw "Must override this method";


}
