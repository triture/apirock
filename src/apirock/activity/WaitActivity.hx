package apirock.activity;

import apirock.ApiRock;
import apirock.helper.ApiRockOut;

class WaitActivity extends Activity {

    private var time:Int;
    private var measure:WaitActivityMeasure;

    public function new(apirock:ApiRock, time:Int, measure:WaitActivityMeasure) {
        super(apirock);

        this.time = time;
        this.measure = measure;
    }

    override private function execute(index:Int):Void {

        ApiRockOut.printIndex('${index+1}.', "Waiting for " + this.time + " " + this.measure + "... ");
        
        switch (this.measure) {
            case WaitActivityMeasure.SECONDS : Sys.sleep(this.time);
            case WaitActivityMeasure.MINUTES : Sys.sleep(this.time * 60);
            case WaitActivityMeasure.HOURS : Sys.sleep(this.time * 60 * 60);
            case _ : Sys.sleep(this.time);
        }

        ApiRockOut.printWithTab('- Done', 2);
    }
}
