import apirock.activity.WaitActivityMeasure;
import apirock.ApiRock;

class ApiRock_Readme {
    public static function main() {
        customTest();
    }

    static function googleTest() {
        new ApiRock("Google Request")

        .makeRequest('Get Google Page')
            .GETting('https://www.google.com')
            .mustPass()
        .then()
        
        .runTests();
    }

    static function waitTest() {
        new ApiRock("Wait Test")

        .makeRequest('Get a simple request')
            .GETting('https://postman-echo.com/get')
            .mustPass()
        .then()

        .waitFor(5, WaitActivityMeasure.SECONDS)
        .then()

        .makeRequest('Get another request after 5 seconds')
            .GETting('https://postman-echo.com/get')
            .mustPass()
        .then()
        
        .runTests();
    }

    static function customTest() {
        
        new ApiRock('Custom Test')
        
        .customActivity(
            function (print:String->Void):Void {

                if (true) print('True is True!');
                else throw 'Something wrong with bools!';

            }
        )
        .then()

        .runTests();

    }
}