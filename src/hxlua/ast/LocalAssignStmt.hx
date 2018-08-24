package hxlua.ast;

class LocalAssignStmt extends StmtBase {
    public var names:Array<String>;
	public var exprs:Array<Expr>;
}