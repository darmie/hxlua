package hxlua.ast;

class IfStmt extends StmtBase {
    public var condition:Expr;
	public var then:Array<Stmt>;
    public var else:Array<Stmt>;  
}