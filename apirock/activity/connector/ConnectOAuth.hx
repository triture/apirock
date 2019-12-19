package apirock.activity.connector;

import utilloader.ULLoader;
import utilloader.ULRequestMethod;
import utilloader.ULRequest;
import utilloader.ULRequestContentType;
import apirock.extensors.Keeper;
import helper.oauth.OAuth2TokenValue;
import helper.oauth.OAuth2AuthorizeValue;
import helper.oauth.OAuth2;
import apirock.strof.Strof;
import helper.kits.CommandLineKit;

class ConnectOAuth extends Activity {

    private var oauthEndPoint:String;
    private var loginEndpoint:String;
    private var scope:String;
    private var username:String;
    private var password:String;

    public var token:OAuth2TokenValue;

    public function new(apirock:APIRock, oauthEndPoint:String, endpoint:String, scope:String, username:String, password:String) {
        super(apirock);

        this.oauthEndPoint = oauthEndPoint;
        this.loginEndpoint = endpoint;
        this.scope = scope;
        this.username = username;
        this.password = password;
    }

    private function authenticate(index:Int, clientId:String, clientSecret:String):Void {

        var authorizeLoaded:Bool = false;
        var authorizeStatus:Bool = false;
        var tokenLoaded:Bool = false;
        var tokenStatus:Bool = false;

        CommandLineKit.printIndex('${index+1}.3.', "Try to get Authorization... ");

        OAuth2.authorize(
            this.oauthEndPoint,
            this.scope,
            clientId,

            function(status:Bool, authorizeValue:OAuth2AuthorizeValue, message:String):Void {
                authorizeStatus = status;

                if (status) {
                    CommandLineKit.printInline('OK');
                    CommandLineKit.printIndex('${index+1}.4.', "Try to get Token... ");

                    OAuth2.token(
                        this.oauthEndPoint,
                        "authorization_code",
                        authorizeValue.code,
                        clientId,
                        clientSecret,
                        function(status:Bool, tokenValue:OAuth2TokenValue, message:String):Void {
                            tokenStatus = status;

                            if (status) {
                                CommandLineKit.printInline('OK');
                                this.token = tokenValue;

                                Keeper.addData("OAUTH_ACCESS_TOKEN", tokenValue.access_token);

                                this.apirock.oauth = this;
                            } else {
                                this.printCatchError("Cannot get Token");
                            }

                            tokenLoaded = true;
                        }
                    );
                } else {
                    this.printCatchError("Cannot get Authorization");
                }

                authorizeLoaded = true;
            }
        );

        while (!authorizeLoaded) Sys.sleep(0.05);
        while (!tokenLoaded) Sys.sleep(0.05);
    }

    override private function execute(index:Int):Void {
        CommandLineKit.printIndex('${index+1}.', "Try to make an OAuth connection to " + this.loginEndpoint);
        CommandLineKit.printIndex('${index+1}.1.', 'Sending credentials [${username}, ${password}]... ');

        var request:ULRequest = new ULRequest(this.loginEndpoint);
        request.method = ULRequestMethod.POST;
        request.contentType = ULRequestContentType.APPLICATION_JSON;
        request.data = {
            username : this.username,
            password : this.password
        };

        var loader:ULLoader = new ULLoader();
        loader.load(request);

        while (!loader.isLoaded) Sys.sleep(0.05);

        if (loader.loadedSuccess) {
            CommandLineKit.printInline("OK");

            var data:Dynamic = haxe.Json.parse(loader.data);

            try {
                CommandLineKit.printIndex('${index+1}.2.', "Validating result... ");

                new Strof()
                .validateString("client_id")
                .validateString("client_secret")
                .validateString("username")
                .validateNumber("id", true)
                .validate(data.data);
            } catch (e:Dynamic) {
                this.printCatchError(e);
            }

            CommandLineKit.printInline("OK");

            // tenta recuperar token
            this.authenticate(index, data.data.client_id, data.data.client_secret);

        } else {
            // erro ao fazer conexao inicial com oauth
            CommandLineKit.printInline("Error : Wrong User or Password ");
            Sys.exit(1);
        }
    }
}
