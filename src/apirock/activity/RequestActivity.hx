package apirock.activity;

import haxe.io.Bytes;
import apirock.ApiRock;
import haxe.ds.StringMap;
import haxe.io.BytesOutput;
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
    private var anonArgs:Array<Dynamic>;
    private var mustFail:Bool = false;
    private var isCriticalRequest:Bool = true;
    private var isCriticalStrof:Bool = true;
    private var mustCode:Null<Int>;

    private var requestUrl:StringKeeper = '';
    private var requestMethod:StringKeeper = 'GET';
    private var requestHedader:Array<KeyValue> = [];
    private var requestDataRaw:StringKeeper;
    private var requestDataRawContentType:StringKeeper;
    private var requestDataJson:StringKeeper;
    private var requestDataForm:Array<KeyValue>;
    private var requestDataQueryString:Array<KeyValue>;

    private var assertData:Assertives = null;
    private var assertHeader:Assertives = null;

    // min / max codes
    public var acceptCodes:Array<Int> = [200, 299];

    public var resultCode:Int = 0;
    public var resultDataBytes:Bytes;
    public var resultData(get, null):String;
    public var resultHeaders:Map<String, String> = new Map<String, String>();

    public function new(apirock:ApiRock, why:StringKeeper, silent:Bool = false) {
        super(apirock, silent);
        this.why = why;
    }

    private function get_resultData():String {
        if (this.resultDataBytes == null) return null;
        else return this.resultDataBytes.toString();
    }

    private function helperGenerateUrlEncodedData(items:Array<KeyValue>):String {
        if (items == null) return '';

        var result:String = '';
        
        var map:StringMap<Array<String>> = new StringMap<Array<String>>();

        for (item in items) {
            var key:String = item.key.toString();
            var value:String = item.value.toString();
            
            var values:Array<String> = [];

            if (map.exists(key)) values = map.get(key);
            else if (map.exists(key + '[]')) values = map.get(key + '[]');
            else map.set(key, values);

            values.push(value);
        }

        for (key in map.keys()) {
            var values:Array<String> = map.get(key);
            var finalKey:String = StringTools.endsWith(key, '[]') ? StringTools.urlEncode(key.substr(0, key.length-2)) + '[]' : StringTools.urlEncode(key);

            if (values.length > 1 && !StringTools.endsWith(finalKey, '[]')) finalKey += '[]';

            for (value in values) {
                result += '${result.length == 0 ? '' : '&'}${finalKey}=${StringTools.urlEncode(value)}';
            }

        }

        return result;
    }

    private function helperGenerateRequestData():RequestData {

        var url:String = this.requestUrl.toString();
        var queryString:String = this.helperGenerateUrlEncodedData(this.requestDataQueryString);

        if (queryString.length > 0) url += '${url.indexOf('?') == -1 ? '?' : '&'}${this.helperGenerateUrlEncodedData(this.requestDataQueryString)}';

        var method:String = this.requestMethod.toString().toUpperCase();

        var headers:StringMap<String> = new StringMap<String>();
        for (header in this.requestHedader) headers.set(header.key.toString().toLowerCase(), header.value);
        
        var data:String = '';
        var dataContentType:String = 'application/x-www-form-urlencoded';
        if (this.requestDataRaw != null) {
            data = this.requestDataRaw.toString();
            dataContentType = this.requestDataRawContentType.toString();
        } else if (this.requestDataForm != null) data = this.helperGenerateUrlEncodedData(this.requestDataForm);
        else if (this.requestDataJson != null) {
            data = this.requestDataJson.toString();
            dataContentType = 'application/json';
        }
        
        if (!headers.exists('content-type')) headers.set('content-type', dataContentType);

        var result:RequestData = {
            url : url,
            method : method,
            data : data,
            headers : headers
        }

        return result;
    }

    private function runAssertive(label:String, assert:Assertives, data:Dynamic, index:Int, subIndex:Int):Int {
        
        this.printIndex('${index + 1}.${++subIndex}.', 'Making Assertives on received ${label}...');
        
        var hasError:Bool = false;

        if (assert.compare(data)) {
            this.printWithTab('- SUCCESS! The received ${label} has the expected values.', 3);
        } else {
            hasError = true;

            var reportError:String = 'ASSERTIVE errors at ${index+1}.${subIndex-1}.';
            this.apirock.errors.push(reportError);

            this.printList(assert.getErrors(), 3);
            this.printWithTab('Received: ${haxe.Json.stringify(data)}', 4);
            this.printWithTab('Compared to: ${Std.string(assert.getAssertive())}', 4);
        }

        if (hasError) {

            this.print('');
            this.printBox('Assertive Error');
            this.print('');

            Sys.exit(301);
        }
        

        return subIndex;
    }

    private function validateData(index:Int, subIndex:Int):Int {
        if (this.assertData != null) {

            var data:Dynamic = this.resultData;

            try {
                if (
                    this.resultHeaders.exists('content-type') && 
                    this.resultHeaders.get('content-type').indexOf('application/json') > -1
                ) data = haxe.Json.parse(this.resultData);
            } catch (e:Dynamic) {

                this.printWithTab("- Error! Received data is not a valid json.", 3);
                
                this.print('');
                this.printBox('Assertive Error');
                this.print('');

                Sys.exit(301);
            }

            subIndex = this.runAssertive('DATA', this.assertData, data, index, subIndex);
        }

        if (this.assertHeader != null) {
            var headerData:Dynamic = {}
            
            for (key in this.resultHeaders.keys()) Reflect.setField(headerData, key, this.resultHeaders.get(key));
            
            subIndex = this.runAssertive('HEADERS', this.assertHeader, headerData, index, subIndex);
        }

        return subIndex;

    }

    override 
    private function execute(index:Int):Void {

        var subIndex:Int = 0;

        if (this.runBefore != null) this.runBefore();

        var requestData:RequestData = this.helperGenerateRequestData();

        this.printIndex(
            '${index + 1}.',
            '[cyan]${this.why.toString().toUpperCase()}[/cyan] making a [cyan]${requestData.method}[/cyan] request to [yellow]${requestData.url}[/yellow]... '
        );

        this.printIndex(
            '${index + 1}.${++subIndex}.',
            'Expecting ${
                this.mustCode != null
                ? 'to get CODE ${this.mustCode}'
                : this.mustFail
                    ? 'to FAIL'
                    : 'SUCCESS'
            }...'
        );

        var runtime:Float = 0;
        var output:BytesOutput = null;
        var doRequest:Void->Void = null;

        doRequest = function():Void {
            output = new BytesOutput();

            var http:haxe.Http = new haxe.Http(requestData.url);
            http.cnxTimeout = 30;
            http.setHeader('User-Agent', 'APIRock');

            for (header in requestData.headers.keys()) {
                http.setHeader(header, requestData.headers.get(header));
                
                #if debug
                this.printWithTab('REQUEST: Header ' + header + ' : ' + requestData.headers.get(header), 3);
                #end
            }

            http.setPostData(requestData.data);

            http.onStatus = function(value:Int):Void {

                #if debug
                this.printWithTab('RESULT: Status ' + Std.string(value), 3);
                #end

                this.resultHeaders = new Map<String, String>();

                if (http.responseHeaders != null) {
                    for (key in http.responseHeaders.keys()) {
                        this.resultHeaders.set(key.toLowerCase(), http.responseHeaders.get(key));

                        #if debug
                        this.printWithTab('RESULT: Header ' + key.toLowerCase() + ' : ' + http.responseHeaders.get(key), 3);
                        #end
                    }
                }

                this.resultCode = value;
                if (value == 301 && this.resultHeaders.exists("location")) {

                    this.printWithTab('- Status 301: Making a redirect to ${Std.string(this.resultHeaders.get("location"))}.', 3);

                    requestData.url = Std.string(resultHeaders.get("location"));
                    doRequest();
                }
            }

            http.onError = function(message:String):Void {}

            runtime = Date.now().getTime();
            http.customRequest(true, output, requestData.method);
        }

        doRequest();

        if (resultCode == 0) {
            this.print('');
            this.printBox('Cannot connect to the URL [red]${requestData.url}[/red]');
            this.print('');

            Sys.exit(300);
        }

        this.resultDataBytes = output.getBytes();
        runtime = Math.fround(Date.now().getTime() - runtime);

        if (this.resultHeaders.exists('content-type') && this.resultHeaders.get('content-type').indexOf('application/json') > -1) {
            #if debug
            this.printWithTab('RESULT: ' + Std.string(this.resultData), 3);
            #end
        }


        this.validateResult(index, runtime);
        subIndex = this.validateAnonStruct(index, subIndex);
        subIndex = this.validateData(index, subIndex);
        subIndex = this.executeKeepers(index, subIndex);

    }

    private function validateResult(index:Int, runTime:Float):Void {
        if (this.resultCode < this.acceptCodes[0] || this.resultCode > this.acceptCodes[1]) {
            if (this.mustCode == null) {

                if (this.mustFail) this.printWithTab('- ERROR in ${runTime}ms! This test should be FAIL.', 3);
                else this.printWithTab('- ERROR in ${runTime}ms! This test should be SUCCESS.', 3);

            } else {
                this.printWithTab('- ERROR in ${runTime}ms! This test should be CODE ${this.mustCode} but received CODE ${this.resultCode}.', 3);
            }

            this.printWithTab(this.resultData, 3);

            if (this.isCriticalRequest) {

                this.print('');
                this.printBox('Error on Critical Request.');
                this.print('');

                Sys.exit(300);

            }

        } else {

            if (this.mustCode == null) {

                if (this.mustFail) this.printWithTab('- SUCCESS in ${runTime}ms. This test should FAIL.', 3);
                else this.printWithTab('- SUCCESS in ${runTime}ms! This test should be SUCCESS.', 3);

            } else {
                this.printWithTab('- SUCCESS in ${runTime}ms! This test expected a code ${this.mustCode}.', 3);
            }
        }
    }

    private function validateAnonStruct(index:Int, subIndex:Int):Int {

        if (this.anonClass != null) {

            this.printIndex('${index + 1}.${++subIndex}.', 'Making structural validation...');

            var data:Dynamic = this.resultData;
            var hasError:Bool = false;

            try {

                if (this.resultHeaders.exists('content-type') && this.resultHeaders.get('content-type').indexOf('application/json') > -1) data = haxe.Json.parse(this.resultData);
                else {
                    try {
                        data = haxe.Json.parse(this.resultData);
                    } catch (e:Dynamic) {}
                }

            } catch (e:Dynamic) {

                this.printWithTab("- ERROR! Received data is not a valid json.", 3);
                hasError = true;

            }

            if (!hasError) {
                try {
                    var anon:AnonStruct = Type.createInstance(this.anonClass, this.anonArgs == null ? [] : this.anonArgs);
                    anon.validateAll(data);

                    this.printWithTab("- Success!", 3);

                } catch (e:Dynamic) {

                    var errors:Array<String> = e;
                    hasError = true;

                    this.printWithTab("- Error", 3);
                    this.printList(errors, 4);

                }
            }

            if (hasError) this.apirock.errors.push('EXPECTATION error at ${index + 1}.${subIndex}.');

            if (hasError && this.isCriticalStrof) {
                this.print('');
                this.printBox('Error on Critical Assertive');
                this.print('');

                Sys.exit(301);
            }
        }

        return subIndex;
    }

    private function executeKeepers(index:Int, subIndex:Int):Int {


        if (this.keepList.length > 0) {

            this.printIndex('${index + 1}.${++subIndex}.', 'Keeping data in memory...');
            var data:Dynamic = null;

            try {
                data = haxe.Json.parse(this.resultData);
            } catch (e:Dynamic) {

            }

            for (keep in this.keepList) keep.runKeeper(data, this.resultHeaders);

        }

        return subIndex;
    }

    public function requesting(url:StringKeeper, method:StringKeeper):RequestDataAndHeaders {
        this.requestUrl = url;
        this.requestMethod = method;
        this.runBefore = null;

        return new RequestDataAndHeaders(this);
    }

    public function POSTing(url:StringKeeper):RequestDataAndHeaders return this.requesting(url, 'POST');
    public function GETting(url:StringKeeper):RequestDataAndHeaders return this.requesting(url, 'GET');
    public function DELETing(url:StringKeeper):RequestDataAndHeaders return this.requesting(url, 'DELETE');
    public function PUTting(url:StringKeeper):RequestDataAndHeaders return this.requesting(url, 'PUT');
    public function PATCHing(url:StringKeeper):RequestDataAndHeaders return this.requesting(url, 'PATCH');
    
}

@:access(apirock.activity.RequestActivity)
private class RequestThen extends Then {

    private var request:RequestActivity;

    public function new(request:RequestActivity) {
        super(request.then());
        this.request = request;
    }

}

@:access(apirock.activity.RequestActivity)
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

@:access(apirock.activity.RequestActivity)
private class RequestKeeperAndDataAsserts extends RequestKeeper {

    public function makeDataAsserts(dataAssert:Dynamic):RequestKeeper {
        
        this.request.assertData = new Assertives();
        this.request.assertData.setAssertive(dataAssert);

        var assert:RequestKeeper = new RequestKeeper(this.request);
        return assert;
    }

}

@:access(apirock.activity.RequestActivity)
private class RequestKeeperAndAsserts extends RequestKeeper {

    public function makeDataAsserts(dataAssert:Dynamic):RequestKeeper return new RequestKeeperAndDataAsserts(this.request).makeDataAsserts(dataAssert);
    
    public function makeHeadAsserts(headAssert:Dynamic):RequestKeeperAndDataAsserts {
        
        this.request.assertHeader = new Assertives();
        this.request.assertHeader.setAssertive(headAssert);

        var assert:RequestKeeperAndDataAsserts = new RequestKeeperAndDataAsserts(this.request);
        return assert;
    }

}

@:access(apirock.activity.RequestActivity)
private class RequestKeeperAndAssertsAndExpecting extends RequestKeeperAndAsserts {

    public function expecting(anon:Class<AnonStruct>, ?args:Array<Dynamic>):RequestKeeperAndAsserts {
        this.request.anonClass = anon;
        this.request.anonArgs = args;
        this.request.isCriticalStrof = true;

        return new RequestKeeperAndAsserts(this.request);
    }
}

@:access(apirock.activity.RequestActivity)
private class RequestKeeperAndAssertsAndExpectingAndMusts extends RequestKeeperAndAssertsAndExpecting {

    public function mustDoCode(?code:Int = 200):RequestKeeperAndAssertsAndExpecting {
        this.request.acceptCodes = [code, code];
        this.request.mustCode = code;
        this.request.isCriticalRequest = true;
        return this;
    }

    public function mustFail():RequestKeeperAndAssertsAndExpecting {
        this.request.acceptCodes = [300, 999];
        this.request.mustFail = true;
        this.request.isCriticalRequest = true;
        return this;
    }

    public function mustPass():RequestKeeperAndAssertsAndExpecting {
        this.request.acceptCodes = [200, 299];
        this.request.mustFail = false;
        this.request.isCriticalRequest = true;
        return this;
    }

}

@:access(apirock.activity.RequestActivity)
private class RequestDataAndHeaders extends RequestKeeperAndAssertsAndExpectingAndMusts {

    public function sendingBearerToken(token:StringKeeper) return this.sendingHeader('Authorization', new StringKeeper('Bearer ') + token);
    

    public function sendingBasicAUTH(username:String, password:String):RequestDataAndHeaders {
        var key:String = haxe.crypto.Base64.encode(haxe.io.Bytes.ofString(username + ':' + password));
        
        return this.sendingHeader('Authorization', 'Basic ' + key);
    }
    
    public function sendingHeader(head:StringKeeper, value:StringKeeper):RequestDataAndHeaders {
        if (this.request.requestHedader == null) this.request.requestHedader = [];
        this.request.requestHedader.push({key:head, value:value});
        return this;
    }

    public function sendingQueryStringData(key:StringKeeper, value:StringKeeper):RequestDataAndHeaders {
        if (this.request.requestDataQueryString == null) this.request.requestDataQueryString = [];
        this.request.requestDataQueryString.push({key:key, value:value});
        return this;
    }

    public function sendingJsonData(data:StringKeeper):RequestKeeperAndAssertsAndExpectingAndMusts {
        this.request.requestDataJson = data;
        return this;
    }

    public function sendingRawData(data:StringKeeper, ?contentType:StringKeeper = 'text/plain'):RequestKeeperAndAssertsAndExpectingAndMusts {
        if (contentType == null || contentType.toString().length == 0) contentType = 'text/plain';
        this.request.requestDataRaw = data;
        this.request.requestDataRawContentType = contentType;
        return this;
    }

    public function sendingFormData(fieldName:StringKeeper, fieldValue:StringKeeper):RequestDataForm {
        return new RequestDataForm(this.request).sendingFormData(fieldName, fieldValue);
    }

}

@:access(apirock.activity.RequestActivity)
private class RequestDataForm extends RequestKeeperAndAssertsAndExpectingAndMusts {
    
    public function sendingFormData(fieldName:StringKeeper, fieldValue:StringKeeper):RequestDataForm {
        if (this.request.requestDataForm == null) this.request.requestDataForm = [];
        this.request.requestDataForm.push({key: fieldName, value: fieldValue});

        return this;
    }

}

private typedef KeyValue = {
    var key:StringKeeper;
    var value:StringKeeper;
}

private typedef RequestData = {
    var url:String;
    var method:String;
    var data:String;
    var headers:StringMap<String>;
}