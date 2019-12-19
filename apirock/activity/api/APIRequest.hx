package apirock.activity.api;

import apirock.strof.Strof;
import helper.anons.AnonStruct;
import utilloader.ULRequestContentType;
import utilloader.ULLoader;
import utilloader.ULRequest;
import utilloader.ULRequestMethod;
import utilloader.ULHeader;
import apirock.assert.Assertives;
import apirock.extensors.Then;
import apirock.types.StringKeeper;
import apirock.extensors.Keeper;
import helper.kits.CommandLineKit;

class APIRequest extends Activity {

    private var why:StringKeeper;
    private var endpoint:StringKeeper;

    private var runBefore:Void->Void;
    private var verb:String;

    @:allow(apirock.activity.api.SendingData)
    @:allow(apirock.activity.api.RequestDataAndExpectations)
    private var postData:Dynamic;

    @:allow(apirock.activity.api.Expectations)
    @:allow(apirock.activity.api.RequestDataAndExpectations)
    private var anonClass:Class<AnonStruct>;

    @:allow(apirock.activity.api.RequestDataAndExpectations)
    private var mustFail:Bool = false;

    @:allow(apirock.activity.api.RequestThen)
    private var isCriticalRequest:Bool = true;

    @:allow(apirock.activity.api.RequestThen)
    private var isCriticalAsserts:Bool = false;

    @:allow(apirock.activity.api.RequestThen)
    private var isCriticalStrof:Bool = true;

    public function new(apirock:APIRock, why:StringKeeper) {
        super(apirock);

        this.why = why;
    }

    private function testData(jsonString:String, index:Int):Void {
        var data:Dynamic = null;
        var subIndex:Int = 0;


        if (this.anonClass != null) {

            try {
                data = haxe.Json.parse(jsonString);
            } catch (e:Dynamic) {
                this.printCatchError("Error on parsing received data \n\n" + Std.string(jsonString));
            }


            subIndex++;
            CommandLineKit.printIndex('${index+1}.${subIndex}.', "Validating Expectations... ");

            try {
                var anon:AnonStruct = Type.createInstance(this.anonClass, []);

                if (Reflect.hasField(data, "data")) {
                    anon.validateAll(data.data);
                } else {
                    anon.validateAll(data);
                }

                CommandLineKit.printInline("OK");

            } catch (e:Dynamic) {
                var errors:Array<String> = e;

                if (this.isCriticalStrof) {

                    this.printCatchError(e);

                } else {
                    CommandLineKit.printInline("ERROR");
                    for (error in errors) CommandLineKit.printTab(" - " + error, 4);

                    var reportError:String = 'EXPECTATION error at ${index+1}.${subIndex}.';
                    this.apirock.errors.push(reportError);
                }
            }
        }

        if (this.assertive != null) {
            var hasAssertiveErrors:Bool = false;

            try {
                data = haxe.Json.parse(jsonString);
            } catch (e:Dynamic) {
                this.printCatchError("Error on parsing received data \n\n" + Std.string(jsonString));
            }

            subIndex++;
            CommandLineKit.printIndex('${index+1}.${subIndex}.', "Making Assertives... ");

            if (this.assertive.compare(data)) {
                CommandLineKit.printInline("OK");
            } else {
                hasAssertiveErrors = true;
                CommandLineKit.printInline("ERROR");
                for (error in this.assertive.getErrors()) CommandLineKit.printTab(" - " + error, 4);

                var reportError:String = 'ASSERTIVE errors at ${index+1}.${subIndex}.';
                this.apirock.errors.push(reportError);
            }

            if (hasAssertiveErrors && this.isCriticalAsserts) {
                CommandLineKit.printInline("\n\n");
                this.printCatchError("ERROR on critical Asserts \n" + haxe.Json.stringify(data));
            }
        }


        if (this.keepList.length > 0) {

            try {
                data = haxe.Json.parse(jsonString);
            } catch (e:Dynamic) {
                this.printCatchError("Error on parsing received data \n\n" + Std.string(jsonString));
            }

            subIndex++;
            CommandLineKit.printIndex('${index+1}.${subIndex}.', "Keeping Data... ");

            for (keep in this.keepList) {
                keep.runKeeper(data);
            }

            CommandLineKit.printInline("OK");
        }
    }

    override private function execute(index:Int):Void {

        if (this.runBefore != null) this.runBefore();

        CommandLineKit.printIndex('${index+1}.', (this.mustFail ? "FAILING " : "TRYING ") + this.why + " at " + this.endpoint + "... ");

        var request:ULRequest = new ULRequest(this.endpoint);
        request.method = this.verb;
        request.contentType = (this.verb == ULRequestMethod.GET) ? ULRequestContentType.FORM_URLENCODED : ULRequestContentType.APPLICATION_JSON;
        request.data = this.postData;

        if (this.apirock.oauth != null && this.apirock.oauth.token != null) {

            var bearer:StringKeeper = "Bearer #OAUTH_ACCESS_TOKEN";

            request.requestHeader = [new ULHeader("Authorization", bearer)];
        }

        var loader:ULLoader = new ULLoader();
        loader.load(request);


        while (!loader.isLoaded) Sys.sleep(0.05);

        if (loader.loadedSuccess) {
            if (this.mustFail) {

                CommandLineKit.printInline("ERROR! This test MUST FAIL!");

                if (this.isCriticalRequest) {

                    CommandLineKit.print("\n\n");
                    CommandLineKit.print(" Loaded Data: " + loader.data);
                    CommandLineKit.print("\n");

                    Sys.exit(1);

                } else {

                    var reportError:String = 'REQUEST SUCCES but should FAIL at ${index+1}. \n --- Loaded: ' + loader.data + "\n";
                    this.apirock.errors.push(reportError);

                }

            } else {
                CommandLineKit.printInline("OK");
                this.testData(loader.data, index);

            }
        } else {
            if (this.mustFail) {
                CommandLineKit.printInline("FAILED! But, it's OK!");
                this.testData(loader.data, index);

            } else {
                CommandLineKit.printInline("Error : Status " + loader.status);

                if (this.isCriticalRequest) {
                    CommandLineKit.print("\n\n " + loader.data);
                    CommandLineKit.print("\n");
                    Sys.exit(1);
                } else {

                    var reportError:String = 'REQUEST FAILED at ${index+1}. \n --- Loaded: ' + loader.data + "\n";
                    this.apirock.errors.push(reportError);

                }
            }
        }
    }

    public function POSTing(endpoint:StringKeeper, ?runBefore:Void->Void):DataAndExpectationsWithFail {
        this.runBefore = runBefore;
        this.verb = ULRequestMethod.POST;
        this.endpoint = endpoint;
        return new DataAndExpectationsWithFail(this);
    }

    public function GETting(endpoint:StringKeeper, ?runBefore:Void->Void):DataAndExpectationsWithFail {
        this.runBefore = runBefore;
        this.verb = ULRequestMethod.GET;
        this.endpoint = endpoint;
        return new DataAndExpectationsWithFail(this);
    }

    public function DELETing(endpoint:StringKeeper, ?runBefore:Void->Void):DataAndExpectationsWithFail {
        this.runBefore = runBefore;
        this.verb = ULRequestMethod.DELETE;
        this.endpoint = endpoint;
        return new DataAndExpectationsWithFail(this);
    }

    public function PUTting(endpoint:StringKeeper, ?runBefore:Void->Void):DataAndExpectationsWithFail {
        this.runBefore = runBefore;
        this.verb = ULRequestMethod.PUT;
        this.endpoint = endpoint;
        return new DataAndExpectationsWithFail(this);
    }
}

private class RequestThen extends Then {

    private var request:APIRequest;

    public function new(request:APIRequest) {
        super(request.then());
        this.request = request;
    }

}



private class RequestDataAndExpectations extends RequestThen {

    public function new(request:APIRequest) super(request);

    public function sending(data:Dynamic):Expectations {
        this.request.postData = data;
        return new Expectations(this.request);
    }

    public function expecting(anon:Class<AnonStruct>, critical:Bool = true):ExpectationsToAsserts {
        this.request.anonClass = anon;
        this.request.isCriticalStrof = critical;

        return new ExpectationsToAsserts(this.request);
    }

    public function keeping(property:String, key:String):Keeper {
        var keeper:Keeper = new Keeper(this.request);
        return keeper.keepingData(property, key);
    }

    public function andMakeAsserts(valueToAssert:Dynamic, critical:Bool = false):MakeAsserts {
        var assertive:Assertives = new Assertives(this.request);
        assertive.setAssertive(valueToAssert);

        this.request.isCriticalAsserts = critical;

        var assert:MakeAsserts = new MakeAsserts(this.request);
        return assert;
    }

}

private class DataAndExpectationsWithFail extends RequestDataAndExpectations {
    public function new(request:APIRequest) {
        super(request);
    }

    public function mustFail(critical:Bool = false):RequestDataAndExpectations {
        this.request.mustFail = true;
        this.request.isCriticalRequest = critical;
        return this;
    }

    public function mustPass(critical:Bool = true):RequestDataAndExpectations {
        this.request.mustFail = false;
        this.request.isCriticalRequest = critical;
        return this;
    }
}

private class SendingData extends RequestThen {

    public function new(request:APIRequest) {
        super(request);
    }

    public function sending(data:Dynamic):Expectations {
        this.request.postData = data;
        return new Expectations(this.request);
    }

    public function keeping(property:String, key:String):Keeper {
        var keeper:Keeper = new Keeper(this.request);
        return keeper.keepingData(property, key);
    }

    public function andMakeAsserts(valueToAssert:Dynamic, critical:Bool = false):MakeAsserts {

        var assertive:Assertives = new Assertives(this.request);
        assertive.setAssertive(valueToAssert);

        this.request.isCriticalAsserts = critical;

        var assert:MakeAsserts = new MakeAsserts(this.request);
        return assert;
    }
}

private class Expectations extends RequestThen {

    public function new(request:APIRequest) {
        super(request);
    }

    public function expecting(anon:Class<AnonStruct>, critical:Bool = true):ExpectationsToAsserts {
        this.request.anonClass = anon;
        this.request.isCriticalStrof = critical;
        return new ExpectationsToAsserts(this.request);
    }

    public function keeping(property:String, key:String):Keeper {
        var keeper:Keeper = new Keeper(this.request);
        return keeper.keepingData(property, key);
    }

    public function andMakeAsserts(valueToAssert:Dynamic, critical:Bool = false):MakeAsserts {
        var assertive:Assertives = new Assertives(this.request);
        assertive.setAssertive(valueToAssert);

        this.request.isCriticalAsserts = critical;

        var assert:MakeAsserts = new MakeAsserts(this.request);
        return assert;
    }
}

private class ExpectationsToAsserts extends RequestThen {

    public function new(request:APIRequest) {
        super(request);
    }

    public function keeping(property:String, key:String):Keeper {
        var keeper:Keeper = new Keeper(this.request);
        return keeper.keepingData(property, key);
    }

    public function andMakeAsserts(valueToAssert:Dynamic, critical:Bool = false):MakeAsserts {
        var assertive:Assertives = new Assertives(this.request);
        assertive.setAssertive(valueToAssert);

        this.request.isCriticalAsserts = critical;

        var assert:MakeAsserts = new MakeAsserts(this.request);
        return assert;
    }
}


private class MakeAsserts extends RequestThen {

    public function new(request:APIRequest) {
        super(request);
    }

    public function keeping(property:String, key:String):Keeper {
        var keeper:Keeper = new Keeper(this.request);
        return keeper.keepingData(property, key);
    }

//    public function andMakeAsserts(valueToAssert:Dynamic, critical:Bool = false):MakeAsserts {
//        var assertive:Assertives = new Assertives(this.request);
//        assertive.setAssertive(valueToAssert);
//
//        this.request.isCriticalAsserts = critical;
//
//        var assert:MakeAsserts = new MakeAsserts(this.request);
//        return assert;
//    }

}
