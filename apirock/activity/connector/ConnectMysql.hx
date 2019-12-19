package apirock.activity.connector;

import sys.db.Mysql;
import sys.db.Connection;
import helper.kits.CommandLineKit;

class ConnectMysql extends Activity {

    private var mysqlUser:String;
    private var mysqlPassword:String;
    private var mysqlHost:String;
    private var connection:Connection;

    public function new(apirock:APIRock, user:String, password:String, host:String) {
        super(apirock);

        this.mysqlUser = user;
        this.mysqlPassword = password;
        this.mysqlHost = host;
    }

    private function connect(index:Int):Void {
        this.connection = Mysql.connect(
            {
                user : this.mysqlUser,
                socket : null,
                port : 3306,
                pass : this.mysqlPassword,
                host : this.mysqlHost,
                database : ""
            }
        );

        CommandLineKit.printInline("OK");
        CommandLineKit.printIndex('${index+1}.2.', "Setting connection to UTF8... ");

        try {
            this.connection.request("SET NAMES utf8");
        } catch (e:Dynamic) {
            CommandLineKit.printInline("Error : Check your Mysql database");
            Sys.exit(1);
        }

        CommandLineKit.printInline("OK");

        this.apirock.sql = this;
    }

    public function request(query:String):Void {
        try {

            this.connection.startTransaction();
            this.connection.request(query);
            this.connection.commit();

        } catch (e:Dynamic) {

            this.connection.rollback();

            CommandLineKit.printInline("ERROR!");

            CommandLineKit.print(" Check your Query:");
            CommandLineKit.print(query);
            CommandLineKit.print("\n\n");
            Sys.exit(1);

        }
    }

    override private function execute(index:Int):Void {
        CommandLineKit.printIndex('${index+1}.', "Try to make a Mysql connection to " + this.mysqlHost);
        CommandLineKit.printIndex('${index+1}.1.', "Connecting... ");

        try {
            this.connect(index);
        } catch (e:Dynamic) {
            CommandLineKit.printInline("Error : Check Credentials");
            Sys.exit(1);
        }
    }
}
