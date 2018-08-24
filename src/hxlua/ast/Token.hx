package hxlua.ast;

class Token {
	public var type:Int;
	public var name:String;
	public var str:String;
	public var pos:Position;

    public function new(op:{type:Null<Int>, name:String, str:String, pos:Position}){
        type = op.type;
        name = op.name;
        str = op.str;
        pos = op.pos;
    }

    public function toString():String {
        return '<type:${name}, str:${str}>';
    }
}