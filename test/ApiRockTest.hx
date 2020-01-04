package ;

import apirock.types.RequestHeader;
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
            .andMakeAsserts({args:{foo:['bar','far'], hey:'you', x:'0'}})
        ;

        apirock.makeRequest('Send json data')
            .POSTing('https://postman-echo.com/post')
            .sendQueryStringData('foo', 'bar')
            .sendingJsonData(haxe.Json.stringify({foo:'bar'}))
            .mustPass()
            .andMakeAsserts({args:{foo:'bar'},json:{foo:'bar'}})
        ;

        apirock.makeRequest('Send form data')
            .POSTing('https://postman-echo.com/post')
            .sendingFormData('field_1', 'value_1')
            .sendingFormData('field_2', 'value_2')
            .sendingFormData('field_arr', '1')
            .sendingFormData('field_arr', '2')
            .mustPass()
            .andMakeAsserts({form:{field_1:'value_1', field_2:'value_2', 'field_arr[]':['1', '2']}})
        ;

        apirock.makeRequest('Send raw data')
            .POSTing('https://postman-echo.com/post')
            .sendingRawData('raw data')
            .mustPass()
            .andMakeAsserts({data:'raw data'})
        ;


        apirock.runTests();

    }

}