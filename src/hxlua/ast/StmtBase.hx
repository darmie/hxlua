package hxlua.ast;

class StmtBase implements Stmt {
    public function line():Int {
        return 0;
    }

    public function setLine(line:Int):Void {

    }

    public function lastLine():Int {
        return 0;
    }

    public function setLastLine(line:Int) {

    }

    private function stmtMarker() {
        
    }    
}