package hxlua.ast;

class AssignStmt extends StmtBase {
    public var lhs:Array<Expr>;
    public var rhs:Array<Expr>;
}