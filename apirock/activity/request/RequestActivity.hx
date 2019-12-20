package apirock.activity.request;

import haxe.io.Bytes;
import haxe.ds.StringMap;
import haxe.io.BytesOutput;
import apirock.types.RequestHeader;
import apirock.types.RequestData;
import apirock.helper.ApiRockOut;
import anonstruct.AnonStruct;
import apirock.assert.Assertives;
import apirock.extensors.Keeper;
import apirock.extensors.Then;
import apirock.types.StringKeeper;

class RequestActivity extends Activity {

    private var why:StringKeeper;
    private var runBefore:Void->Void;
    private var anonClass:Class<AnonStruct>;
    private var mustFail:Bool = false;
    private var isCriticalRequest:Bool = true;
    private var isCriticalAsserts:Bool = false;
    private var isCriticalStrof:Bool = true;
    private var mustCode:Null<Int>;
    private var requestData:RequestData;

    // min / max codes
    public var acceptCodes:Array<Int> = [200, 299];

    public var resultCode:Int = 0;
    public var resultData:String = "";
    public var resultHeaders:Map<String, String> = new Map<String, String>();

    public function new(apirock:APIRock, why:StringKeeper) {
        super(apirock);

        this.why = why;
    }

    private function validateData(index:Int, subIndex:Int):Int {
        if (this.assertive != null) {

            ApiRockOut.printIndex('${index + 1}.${++subIndex}.', 'Making Assertives validation...');

            var data:Dynamic = this.resultData;
            var hasError:Bool = false;

            try {

                if (
                    this.resultHeaders.exists('content-type')
                    && this.resultHeaders.get('content-type').indexOf('application/json') > -1
                ) data = haxe.Json.parse(this.resultData);

            } catch (e:Dynamic) {

                ApiRockOut.printWithTab("- Error! Received data is not a valid json.", 3);
                hasError = true;

            }

            if (data != null) {
                if (this.assertive.compare(data)) {
                    ApiRockOut.printWithTab("- SUCCESS! The received data has the expected values.", 3);
                } else {
                    hasError = true;

                    var reportError:String = 'ASSERTIVE errors at ${index+1}.${subIndex-1}.';
                    this.apirock.errors.push(reportError);
                }
            }

            ApiRockOut.printList(this.assertive.getErrors(), 3);

            if (hasError && this.isCriticalAsserts) {

                ApiRockOut.print('');
                ApiRockOut.printBox('Error on Critical Assertive');
                ApiRockOut.print('');

                Sys.exit(301);

            }
        }

        return subIndex;

    }

    override private function execute(index:Int):Void {

        var subIndex:Int = 1;

        if (this.runBefore != null) this.runBefore();

        ApiRockOut.printIndex(
            '${index + 1}.',
            'Trying to ${this.why} making a ${this.requestData.method.toString().toUpperCase()} request at ${this.requestData.url}... '
        );

        ApiRockOut.printIndex(
            '${index + 1}.${++subIndex}.',
            'Expecting ${
                this.mustCode != null
                ? 'to get CODE ${this.mustCode}'
                : this.mustFail
                    ? 'to FAIL'
                    : 'SUCCESS'
            }...'
        );

        var output:BytesOutput = null;
        var doRequest:Void->Void = null;

        doRequest = function():Void {

            output = new BytesOutput();

            var http:haxe.Http = new haxe.Http(this.requestData.url);

            for (header in this.requestData.headers) http.setHeader(header.header, header.value);
            http.setPostData(this.requestData.data);

            http.onStatus = function(value:Int):Void {

                this.resultHeaders = new Map<String, String>();

                if (http.responseHeaders != null) {
                    for (key in http.responseHeaders.keys()) {
                        this.resultHeaders.set(key.toLowerCase(), http.responseHeaders.get(key));
                    }
                }

                this.resultCode = value;
                if (value == 301 && this.resultHeaders.exists("location")) {

                    ApiRockOut.printWithTab('- Status 301: Making a redirect to ${Std.string(this.resultHeaders.get("location"))}.', 3);

                    this.requestData.url = Std.string(this.resultHeaders.get("location"));
                    doRequest();
                }
            }

            http.onError = function(message:String):Void {

            }

            http.customRequest(true, output, this.requestData.method.toString().toUpperCase());
        }

        doRequest();

        this.resultData = output.getBytes().toString();

        this.validateResult(index);
        subIndex = this.validateData(index, subIndex);
        subIndex = this.validateAnonStruct(index, subIndex);
        subIndex = this.executeKeepers(index, subIndex);

    }

    private function validateResult(index:Int):Void {
        if (this.resultCode < this.acceptCodes[0] || this.resultCode > this.acceptCodes[1]) {
            if (this.mustCode == null) {

                if (this.mustFail) ApiRockOut.printWithTab("- Error! This test should be FAIL.", 3);
                else ApiRockOut.printWithTab("- Error! This test should be SUCCESS.", 3);

            } else {
                ApiRockOut.printWithTab('- Error! This test should be CODE ${this.mustCode} but received CODE ${this.resultCode}.', 3);
            }

            if (this.isCriticalRequest) {

                ApiRockOut.print('');
                ApiRockOut.printBox('Error on Critical Request.');
                ApiRockOut.print('');

                Sys.exit(300);

            }

        } else {

            if (this.mustCode == null) {

                if (this.mustFail) ApiRockOut.printWithTab("- SUCCESS. This test should FAIL.", 3);
                else ApiRockOut.printWithTab("- SUCCESS. This test should be SUCCESS.", 3);

            } else {
                ApiRockOut.printWithTab('- SUCCESS! This test expected a code ${this.mustCode}.', 3);
            }
        }
    }

    private function validateAnonStruct(index:Int, subIndex:Int):Int {

        if (this.anonClass != null) {

            ApiRockOut.printIndex('${index + 1}.${++subIndex}.', 'Making structural validation...');

            var data:Dynamic = this.resultData;
            var hasError:Bool = false;

            try {

                if (
                    this.resultHeaders.exists('content-type')
                    && this.resultHeaders.get('content-type').indexOf('application/json') > -1
                ) data = haxe.Json.parse(this.resultData);

            } catch (e:Dynamic) {

                ApiRockOut.printWithTab("- Error! Received data is not a valid json.", 3);
                hasError = true;

            }

            if (!hasError) {
                try {
                    var anon:AnonStruct = Type.createInstance(this.anonClass, []);
                    anon.validateAll(data);

                    ApiRockOut.printWithTab("- Success!", 3);

                } catch (e:Dynamic) {

                    var errors:Array<String> = e;
                    hasError = true;

                    ApiRockOut.printWithTab("- Error", 3);
                    ApiRockOut.printList(errors, 4);

                }
            }

            if (hasError) this.apirock.errors.push('EXPECTATION error at ${index + 1}.${subIndex}.');

            if (hasError && this.isCriticalStrof) {
                ApiRockOut.print('');
                ApiRockOut.printBox('Error on Critical Assertive');
                ApiRockOut.print('');

                Sys.exit(301);
            }
        }

        return subIndex;
    }

    private function executeKeepers(index:Int, subIndex:Int):Int {


        if (this.keepList.length > 0) {

            ApiRockOut.printIndex('${index + 1}.${++subIndex}.', 'Keeping data in memory...');
            var data:Dynamic = null;

            try {
                data = haxe.Json.parse(this.resultData);
            } catch (e:Dynamic) {

            }

            for (keep in this.keepList) keep.runKeeper(data, this.resultHeaders);

        }

        return subIndex;
    }

    public function requesting(requestData:RequestData, ?runBefore:Void->Void):RequestKeeperAndAssertsAndExpectingAndMusts {
        this.requestData = requestData;
        this.runBefore = runBefore;

        return new RequestKeeperAndAssertsAndExpectingAndMusts(this);
    }

    private function requestHelper(url:StringKeeper, data:Dynamic, method:String):RequestData {

        var contentType:String = "application/x-www-form-urlencoded";
        var resultData:String = "";

        if (data == null) contentType = "application/x-www-form-urlencoded";
        else if (Std.is(data, String) || Std.is(data, Int) || Std.is(data, Float)) {

            resultData = Std.string(data);


            if (resultData.length == 0) contentType = "application/x-www-form-urlencoded";
            else {
                // is json string
                try {
                    var jsonObject:Dynamic = haxe.Json.parse(data);
                    contentType = "application/json";

                } catch (e:Dynamic) {
                    contentType = "multipart/form-data";
                }

            }
        } else {
            try {
                resultData = haxe.Json.stringify(data);
                contentType = "application/json";
            } catch(e:Dynamic) {

            }
        }

        var requester:RequestData = {
            url : url,
            method : method,
            data : resultData,
            headers : [new RequestHeader('content-type', contentType)]
        }

        return requester;
    }

    public function POSTing(url:StringKeeper, ?data:Dynamic, ?runBefore:Void->Void):RequestKeeperAndAssertsAndExpectingAndMusts {
        return this.requesting(
            this.requestHelper(url, data, "POST"),
            runBefore
        );
    }

    public function GETting(url:StringKeeper, ?data:Dynamic, ?runBefore:Void->Void):RequestKeeperAndAssertsAndExpectingAndMusts {
        return this.requesting(
            this.requestHelper(url, data, "GET"),
            runBefore
        );
    }

    public function DELETing(url:StringKeeper, ?data:Dynamic, ?runBefore:Void->Void):RequestKeeperAndAssertsAndExpectingAndMusts {
        return this.requesting(
            this.requestHelper(url, data, "DELETE"),
            runBefore
        );
    }

    public function PUTting(url:StringKeeper, ?data:Dynamic, ?runBefore:Void->Void):RequestKeeperAndAssertsAndExpectingAndMusts {
        return this.requesting(
            this.requestHelper(url, data, "PUT"),
            runBefore
        );
    }
}

@:access(apirock.activity.request.RequestActivity)
private class RequestThen extends Then {

    private var request:RequestActivity;

    public function new(request:RequestActivity) {
        super(request.then());
        this.request = request;
    }

}

@:access(apirock.activity.request.RequestActivity)
private class RequestKeeper extends RequestThen {

    public function keepingData(property:String, key:String):Keeper {
        var keeper:Keeper = new Keeper(this.request);
        return keeper.keepingData(property, key);
    }

    public function keepingHeader(header:String, key:String):Keeper {
        var keeper:Keeper = new Keeper(this.request);
        return keeper.keepingHeader(header, key);
    }

}

@:access(apirock.activity.request.RequestActivity)
private class RequestKeeperAndAsserts extends RequestKeeper {

    public function andMakeAsserts(valueToAssert:Dynamic, ?critical:Bool = true):RequestKeeper {

        var assertive:Assertives = new Assertives(this.request);
        assertive.setAssertive(valueToAssert);

        this.request.isCriticalAsserts = critical;

        var assert:RequestKeeper = new RequestKeeper(this.request);
        return assert;
    }

}

@:access(apirock.activity.request.RequestActivity)
private class RequestKeeperAndAssertsAndExpecting extends RequestKeeperAndAsserts {

    public function expecting(anon:Class<AnonStruct>, critical:Bool = true):RequestKeeperAndAsserts {
        this.request.anonClass = anon;
        this.request.isCriticalStrof = critical;

        return new RequestKeeperAndAsserts(this.request);
    }

}

@:access(apirock.activity.request.RequestActivity)
private class RequestKeeperAndAssertsAndExpectingAndMusts extends RequestKeeperAndAssertsAndExpecting {

    public function mustDoCode(?code:Int = 200, ?critical:Bool = true):RequestKeeperAndAssertsAndExpecting {
        this.request.acceptCodes = [code, code];
        this.request.mustCode = code;
        this.request.isCriticalRequest = critical;
        return this;
    }

    public function mustFail(critical:Bool = false):RequestKeeperAndAssertsAndExpecting {
        this.request.acceptCodes = [300, 999];
        this.request.mustFail = true;
        this.request.isCriticalRequest = critical;
        return this;
    }

    public function mustPass(critical:Bool = true):RequestKeeperAndAssertsAndExpecting {
        this.request.acceptCodes = [200, 299];
        this.request.mustFail = false;
        this.request.isCriticalRequest = critical;
        return this;
    }

}
