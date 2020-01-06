
[![Build Status](https://travis-ci.org/triture/apirock.svg?branch=master)](https://travis-ci.org/triture/apirock)

# ApiRock
Just another API testing library.

Example:
```haxe
new ApiRock("Postman Echo")                     // Create your test using 'Fluent Interface'

.makeRequest('Get a simple request')            // Add a test cases
    .GETting('https://postman-echo.com/get')
    .sendQueryStringData('foo', 'bar')
    .mustPass()
    .makeDataAsserts({args:{foo:'bar'}})
.then()

.makeRequest('Testing received headers')        // Add another test...
    .GETting('https://postman-echo.com/response-headers')
    .sendQueryStringData('foo', 'bar')
    .mustPass()
    .makeHeadAsserts({foo:'bar'})
.then()

.runTests();                                    // then RUN!
```

## Activities
ApiRock is in fact a stack of activities. After you write your group of activities, ApiRock will run everithing in order. If something fails, the test is finished with error.

### Request Activity
The heart of ApiRock is make API requests and check if everything is OK.

```haxe
new ApiRock("Google Request")

.makeRequest('Get Google Page')
    .GETting('https://www.google.com')
    .mustPass()
.then()

.runTests();
```

**makeRequest(why:StringKeeper)**
Params | Description
- | -
why | Explain why you need this request

### Wait Activity
If you need wait some time between activities, use the Wait Activity.

```haxe
new ApiRock("Wait Test")

.makeRequest('Get a simple request')
    .GETting('https://postman-echo.com/get')
    .mustPass()
.then()

.waitFor(5, WaitActivityMeasure.SECONDS)
.then()

.makeRequest('Get another request after 5 secods')
    .GETting('https://postman-echo.com/get')
    .mustPass()
.then()

.runTests();
```

**waitFor(time:Int, ?measure:WaitActivityMeasure)**
Params | Description
- | -
time | The amount of time to wait
measure | The unity of time. Can be Hour, Minutes or Seconds (***default***)

### Clear StringKeeper Activity
Use this activity if you need to clear all data stored on StringKeeper.

**clearStringKeeper()**

### Custom Activity
If you need to execute some very specific tasks, use Custom Activities.

```haxe
new ApiRock('Custom Test')
        
.customActivity(
    function (print:String->Void):Void {

        if (true) print('True is True!');
        else throw 'Something wrong with bools!';

    }
)
.then()

.runTests();
```