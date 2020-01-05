package ;

import apirock.ApiRock;

class ApiRockTest {
    
    static public function main() {
        
        var apirock:ApiRock = new ApiRock("Postman Echo");

        // GET GET Request
        apirock.makeRequest('Get a simple request')
            .GETting('https://postman-echo.com/get?x=0')
            .sendQueryStringData('foo', 'bar')
            .sendQueryStringData('foo', 'far')
            .sendQueryStringData('hey', 'you')
            .mustPass()
            .makeDataAsserts({args:{foo:['bar','far'], hey:'you', x:'0'}})
        .then()

        .makeRequest('Send json data')
            .POSTing('https://postman-echo.com/post')
            .sendQueryStringData('foo', 'bar')
            .sendingJsonData(haxe.Json.stringify({foo:'bar'}))
            .mustPass()
            .makeDataAsserts({args:{foo:'bar'},json:{foo:'bar'}})
        .then()

        .makeRequest('Send form data')
            .POSTing('https://postman-echo.com/post')
            .sendingFormData('field_1', 'value_1')
            .sendingFormData('field_2', 'value_2')
            .sendingFormData('field_arr', '1')
            .sendingFormData('field_arr', '2')
            .mustPass()
            .makeDataAsserts({form:{field_1:'value_1', field_2:'value_2', 'field_arr[]':['1', '2']}})
        .then()
        
        .makeRequest('Send raw data')
            .POSTing('https://postman-echo.com/post')
            .sendingRawData('raw data')
            .mustPass()
            .makeDataAsserts({data:'raw data'})
        .then()
        
        .makeRequest('Testing put method')
            .PUTting('https://postman-echo.com/put')
            .mustPass()
            .makeDataAsserts({data:''})
        .then()

        .makeRequest('Testing patch method')
            .PATCHing('https://postman-echo.com/patch')
            .mustPass()
            .makeDataAsserts({data:''})
        .then()
    
        .makeRequest('Testing delete method')
            .DELETing('https://postman-echo.com/delete')
            .mustPass()
            .makeDataAsserts({data:''})
        .then()
        
        .makeRequest('Testing sending headers')
            .GETting('https://postman-echo.com/headers')
            .sendingHeader('my-header', 'header value')
            .makeDataAsserts({headers:{'my-header': 'header value'}})
        .then()

        .makeRequest('Testing received headers')
            .GETting('https://postman-echo.com/response-headers')
            .sendQueryStringData('foo', 'bar')
            .makeHeadAsserts({foo:'bar'})
        .then()

        .runTests();

    }

}