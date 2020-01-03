package apirock.extensors;

import apirock.ApiRock;

class Then {

    private var apirock:ApiRock;
    
    public function new(apirock:ApiRock) this.apirock = apirock;

    public function then():ApiRock return this.apirock;
    
}
