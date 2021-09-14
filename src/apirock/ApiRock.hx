package apirock;

import apirock.activity.CustomActivity;
import apirock.activity.ClearStringKeeperActivity;
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

    public function makeRequest(why:StringKeeper, silent:Bool = false):RequestActivity {
        var requester:RequestActivity = new RequestActivity(this, why, silent);
        this.addActivity(requester);
        return requester;
    }
    
    public function waitFor(time:Int, ?measure:WaitActivityMeasure):WaitActivity {
        var wait:WaitActivity = new WaitActivity(this, time, measure == null ? WaitActivityMeasure.SECONDS : measure);
        this.activityStack.push(wait);
        return wait;
    }

    public function clearStringKeeper():ClearStringKeeperActivity {
        var clear:ClearStringKeeperActivity = new ClearStringKeeperActivity(this);
        this.activityStack.push(clear);
        return clear;
    }

    public function customActivity(run:(outputFunction:(value:String)->Void)->Void):CustomActivity {
        var custom:CustomActivity = new CustomActivity(this, run);
        this.activityStack.push(custom);
        return custom;
    }
    
    public function runTests():Void {

        ApiRockOut.printTitle("Running APIProck " + this.name);

        var index:Int = 0;
        for (item in this.activityStack) {
            if (!item.silent) ApiRockOut.print("");
            item.execute(index);
            if (!item.silent) index++;
        }


        if (this.errors.length == 0) {

            ApiRockOut.printBox("[green]DONE[/green]");

        } else {

            ApiRockOut.print("");
            ApiRockOut.printBox("ERRORS FOUND ON ROUTINE");
            ApiRockOut.print("   - " + this.errors.join("\n   - "));
            ApiRockOut.print("");
            ApiRockOut.print("");

            Sys.exit(1);

        }
    }

}
