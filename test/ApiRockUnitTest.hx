package ;

import cases.CaseStringKeeper;
import cases.CaseAssertives;
import utest.ui.Report;
import utest.Runner;

class ApiRockUnitTest {
    
    static public function main() {
        
        var runner = new Runner();

        runner.addCase(new CaseAssertives());
        runner.addCase(new CaseStringKeeper());

        Report.create(runner);
        runner.run();

    }

}