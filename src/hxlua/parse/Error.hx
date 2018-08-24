package hxlua.parse;

import hxlua.ast.*;
import hxlua.parse.Constants;

class Error  {
	public var pos:Position;
	public var message:String;
	public var token:String;

    public function new(op:{pos:Position, message:String, token:String}) {
        pos = op.pos;
        message = op.message;
        token = op.token;
    } 

    public function error():String {
        var pos = this.pos;

        if(pos.line == EOF){
            return '${pos.source} at EOF:   ${message}\n';
        } else  {
            return '${pos.source} line:${pos.line}(column:${pos.column}) near '${this.token}':   ${this.message}\n';
        }
    }
}