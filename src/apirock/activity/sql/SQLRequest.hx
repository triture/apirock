package apirock.activity.sql;

import helper.kits.CommandLineKit;
import apirock.extensors.Then;
import apirock.types.StringKeeper;

class SQLRequest extends Activity {

    private var why:StringKeeper;
    private var query:StringKeeper;

    public function new(apirock:APIRock, why:StringKeeper) {
        super(apirock);

        this.why = why;
    }

    public function querying(sql:StringKeeper):Then {
        this.query = sql;
        return new Then(this.apirock);
    }

    override private function execute(index:Int):Void {

        CommandLineKit.printIndex('${index+1}.', "TRYING " + this.why + "... ");

        CommandLineKit.printIndex('${index+1}.0.', "Running Query...");

        this.apirock.sql.request(this.query);

        CommandLineKit.printInline("OK");

    }
}
