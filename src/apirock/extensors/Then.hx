package apirock.extensors;

class Then {

    private var apirock:APIRock;

    public function new(apirock:APIRock) {
        this.apirock = apirock;
    }

    public function then():APIRock {
        return this.apirock;
    }
}
