package apirock;

import apirock.activity.request.RequestActivity;
import apirock.types.StringKeeper;
import apirock.activity.Activity;
import apirock.helper.ApiRockOut;

class APIRock {

    private var name:String;

    private var activityStack:Array<Activity> = [];

//    @:allow(apirock.activity.api.APIRequest)
//    @:allow(apirock.activity.connector.ConnxectOAuth)
//    private var oauth:ConnectOAuth;
//
//    @:allow(apirock.activity.sql.SQLRequest)
//    @:allow(apirock.activity.connector.ConnectMysql)
//    private var sql:ConnectMysql;

    public var errors:Array<String> = [];

    public function new(name:String) {
        this.name = name;
    }

//    public function waitFor(time:Int, measure:WaitTimeMeasure = WaitTimeMeasure.SECONDS):Wait {
//        var wait:Wait = new Wait(this, time, measure);
//
//        this.activityStack.push(wait);
//
//        return wait;
//    }
//
//    public function makeOAuthConnection(oauthEndPoint:String, loginEndPoint:String, scope:String, login:String, password:String):ConnectOAuth {
//        var oauth = new ConnectOAuth(this, oauthEndPoint, loginEndPoint, scope, login, password);
//        this.activityStack.push(oauth);
//        return oauth;
//    }
//
//    public function makeMysqlConnection(user:String, password:String, host:String):ConnectMysql {
//        var sql = new ConnectMysql(this, user, password, host);
//        this.activityStack.push(sql);
//        return sql;
//    }
//
//    public function makeAPIRequest(why:StringKeeper):APIRequest {
//        var api:APIRequest = new APIRequest(this, why);
//        this.activityStack.push(api);
//        return api;
//    }

    public function makeRequest(why:StringKeeper):RequestActivity {
        var requester:RequestActivity = new RequestActivity(this, why);
        this.activityStack.push(requester);
        return requester;
    }
//
//    public function makeSQLQuery(why:StringKeeper):SQLRequest {
//        var sql:SQLRequest = new SQLRequest(this, why);
//        this.activityStack.push(sql);
//        return sql;
//    }
//

    public function runTests():APIRock {

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
