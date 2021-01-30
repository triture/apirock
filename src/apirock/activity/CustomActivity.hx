package apirock.activity;

import apirock.helper.ApiRockOut;

class CustomActivity extends Activity {
    
    private var customFunction:(outputFunction:(value:String)->Void)->Void;

    public function new(apirock:ApiRock, customFunction:(outputFunction:(value:String)->Void)->Void) {
        this.customFunction = customFunction;
        super(apirock);
    }

    override private function execute(index:Int):Void {
        ApiRockOut.printIndex('${index+1}.', "Running Custom Activity...");
        
        if (customFunction != null) {
            try {
                customFunction(this.message);
                ApiRockOut.printWithTab('- Done', 2);
            } catch(e:Dynamic) {
                
                ApiRockOut.printWithTab('- Error! ' + Std.string(e), 2);

                ApiRockOut.print('');
                ApiRockOut.printBox('Error on Custom Activity');
                ApiRockOut.print('');

                Sys.exit(305);

            }
        } else ApiRockOut.printWithTab('- Done', 2);
    }

    private function message(info:String):Void ApiRockOut.printWithTab('- ' + info, 2);
    

}