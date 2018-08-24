package hxlua.parse;

import haxe.display.JsonModuleTypes.JsonTodo;
import hxlua.parse.Parser.YYSymType;
import hxlua.ast.*;


typedef TLexer = {
	scanner:Scanner,
	stmts:Array<Stmt>,
	pNewLine:Bool,
	token:Token,
	prevTokenType:Int,   
}

class Lexer {
	public var scanner:Scanner;
	public var stmts:Array<Stmt>;
	public var pNewLine:Bool;
	public var token:Token;
	public var prevTokenType:Int;

    public function new(op:TLexer){
        this.pNewLine = op.pNewLine;
        this.prevTokenType = op.prevTokenType;
        this.scanner = op.scanner;
        this.stmts = op.stmts;
        this.token = op.token;
    }


    public function lex(lval:YYSymType):Int {
        this.prevTokenType = this.token.type;
        var tok:Token = null;

        try {
            tok = this.scanner.scan(this);
        } catch(e:Dynamic){
            throw e;
        }

        if(tok.type < 0){
            return 0;
        }

        lval.token = tok;
        this.token = tok;

        return token.type;
    }

    public function error(message:String){
        throw this.scanner.error(this.token.str, message);
    }

    public function tokenError(tok:Token, message:String) {
        throw this.scanner.tokenError(tok, message);
    }
}