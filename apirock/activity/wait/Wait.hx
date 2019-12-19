package apirock.activity.wait;

import helper.kits.CommandLineKit;
class Wait extends Activity {

    private var time:Int;
    private var measure:WaitTimeMeasure;

    public function new(apirock:APIRock, time:Int, measure:WaitTimeMeasure) {
        super(apirock);

        this.time = time;
        this.measure = measure;
    }

    override private function execute(index:Int):Void {

        CommandLineKit.printIndex('${index+1}.', "Waiting for " + this.time + " " + this.measure + "... ");

        switch (this.measure) {
            case WaitTimeMeasure.SECONDS : Sys.sleep(this.time);
            case WaitTimeMeasure.MINUTES : Sys.sleep(this.time * 60);
            case WaitTimeMeasure.HOURS : Sys.sleep(this.time * 60 * 60);
            case _ : Sys.sleep(this.time);
        }

        CommandLineKit.printInline("OK");
    }
}
