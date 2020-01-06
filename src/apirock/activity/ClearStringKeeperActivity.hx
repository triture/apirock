package apirock.activity;

import apirock.types.StringKeeper;
import apirock.helper.ApiRockOut;

class ClearStringKeeperActivity extends Activity {
    
    override private function execute(index:Int):Void {
        ApiRockOut.printIndex('${index+1}.', "Removing all data from StringKeeper");
        
        StringKeeper.clear();

        ApiRockOut.printWithTab('- Done', 2);
    }

}