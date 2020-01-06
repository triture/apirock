
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