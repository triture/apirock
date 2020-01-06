package apirock;

import apirock.activity.WaitActivity;
import apirock.activity.WaitActivityMeasure;
import apirock.activity.RequestActivity;
import apirock.types.StringKeeper;
import apirock.activity.Activity;
import apirock.helper.ApiRockOut;

class ApiRock {

    private var name:String;

    private var activityStack:Array<Activity> = [];

    public var errors:Array<String> = [];

    public function new(name:String) {
        this.name = name;
    }

    public function addActivity(activity:Activity):Void this.activityStack.push(activity);

    public function makeRequest(why:StringKeeper):RequestActivity {
        var requester:RequestActivity = new RequestActivity(this, why);
        this.addActivity(requester);
        return requester;
    }
    
    public function waitFor(time:Int, measure:WaitActivityMeasure):WaitActivity {
        var wait:WaitActivity = new WaitActivity(this, time, measure == null ? WaitActivityMeasure.SECONDS : measure);
        this.activityStack.push(wait);
        return wait;
    }
    
    public function runTests():ApiRock {

        ApiRockOut.printTitle("Running APIProck " + this.name);

        var index:Int = 0;
        for (item in this.activityStack) {

            ApiRockOut.print("");
            item.execute(index);

            index++;
        }


        if (this.errors.length == 0) {

            ApiRockOut.printBox("DONE");
            Sys.exit(0);

        } else {

            ApiRockOut.print("");
            ApiRockOut.printBox("ERRORS FOUND ON ROUTINE");
            ApiRockOut.print("   - " + this.errors.join("\n   - "));
            ApiRockOut.print("");
            ApiRockOut.print("");

            Sys.exit(1);

        }

        return this;
    }

}
