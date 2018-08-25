package hxlua.parse;

import haxe.io.StringInput;
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import haxe.io.Eof;
import hxlua.ast.*;
using hxlua.parse.Constants;
using hxlua.parse.Parser;


class Scanner {
    public var pos:Position;
    public var reader:haxe.io.Input;

    public function new(reader:haxe.io.Input, source:String) {
        this.pos = {
            source: source,
            line: 1,
            column: 0
        };

    }


    public function error(tok:String, msg:String):Error {
        return new Error({
            token: tok,
            pos: this.pos,
            message: msg
        });
    }

    static function writeChar(buf:StringBuf, c:Int) buf.addChar(c);

    static function isDecimal(ch:Int):Bool { return '0'.charCodeAt(0) <= ch && ch <= '9'.charCodeAt(0); }

    static function isIdent(ch:Int, pos:Int):Bool {
        return ch == '_'.charCodeAt(0) || 'A'.charCodeAt(0) <= ch && ch <= 'Z'.charCodeAt(0) || 'a'.charCodeAt(0) <= ch && ch <= 'z'.charCodeAt(0) || isDecimal(ch) && pos > 0;
    }

    static function isDigit(ch:Int):Bool {
        return '0'.charCodeAt(0) <= ch && ch <= '9'.charCodeAt(0) || 'a'.charCodeAt(0) <= ch && ch <= 'f'.charCodeAt(0) || 'A'.charCodeAt(0) <= ch && ch <= 'F'.charCodeAt(0);
    }

    public function tokenError(tok:Token, msg:String):Error {
        return new Error({
            token: tok.str,
            pos: this.pos,
            message: msg
        });        
    }

    public function readNext():Int {
        var ch:Int;
        try{
            ch = this.reader.readByte();
            return ch;
        } catch(e:Eof) {
            return EOF;
        }
    }

    public function newLine(ch:Int) {
        if (ch < 0) {
            return;
        }   

        this.pos.line += 1;
        this.pos.column = 0;

        var next = this.peek();

        if (ch == '\n'.charCodeAt(0) && next == '\r'.charCodeAt(0) || ch == '\r'.charCodeAt(0) && next == '\n'.charCodeAt(0)) {
            this.reader.readByte();
        }   
    }

    public function next():Int {
        var ch = this.readNext();

        function char(str:String):Int return str.charCodeAt(0);

        switch ch {
            //check '\n' or '\r'
            case 9 | 13 : { 
                this.newLine(ch);
                ch = '\n'.charCodeAt(0);
            }
            case EOF: {
                this.pos.line = EOF;
                this.pos.column = 0;
            }
            default: {
                this.pos.column++;
            }
        }

        return ch;
    }

    public function peek():Int {
        var ch = this.readNext();
        return ch;
    }

    private function skipWhiteSpace(whitespace:Int):Int {
        var ch = next();

        while(whitespace&(1<<ch) != 0) {
            ch = this.next();
        }

        return ch;
    }

    private function skipComments(ch:Int):Error {
        // multiline comment
        if (this.peek() == '['.charCodeAt(0)) {
            ch = this.next();

            if(peek() == '['.charCodeAt(0) || peek() == '='.charCodeAt(0)) {
                var buf = new StringBuf();
                try{
                    scanMultilineString(next(), buf);
                    return this.error(buf.toString(), "invalid multiline comment");
                } catch (e:Dynamic) {
                    return null;
                }
            }
        }

        while(true) {
            if (ch == '\n'.charCodeAt(0) || ch == '\r'.charCodeAt(0) || ch < 0) {
                break;
            }
            ch = this.next();       
        }

        return null;
    }

    function scanIdent(ch:Int, buf:StringBuf):Error {
        writeChar(buf, ch);

        while(isIdent(this.peek(), 1)) {
            writeChar(buf, next());
        }

        return null;
    }

    function scanDecimal(ch:Int, buf:StringBuf):Error {
        writeChar(buf, ch);

        while (isDecimal(this.peek())) {
		    writeChar(buf, this.next());
	    }

        return null;
    }

    function scanNumber(ch:Int, buf:StringBuf):Error {
        if (ch == '0'.charCodeAt(0)) { // octal 
            if (peek() == 'x'.charCodeAt(0) || peek() == 'X'.charCodeAt(0)) {
                writeChar(buf, ch);
                writeChar(buf, next());

                var hasvalue = false;

                if(!hasvalue) {
                    return error(buf.toString(), "illegal hexadecimal number");
                }
                return null;
            } else if(peek() != '.'.charCodeAt(0) && isDecimal(peek())){
                ch = next();
            }
        }

        scanDecimal(ch, buf);

        if(peek() == '.'.charCodeAt(0)) {
            scanDecimal(next(), buf);
        }

        ch = peek();
        if(ch == 'e'.charCodeAt(0) || ch == 'E'.charCodeAt(0)) {
            writeChar(buf, next());
            ch = peek();
            if (ch == '-'.charCodeAt(0) || ch == '+'.charCodeAt(0)) {
                writeChar(buf, next());
            }
            scanDecimal(next(), buf);
        }

        return null;
    }

    function scanString(quote:Int, buf:StringBuf):Error {
        var ch = next();

        while(ch != quote) {
            if (ch == '\n'.charCodeAt(0) || ch == '\r'.charCodeAt(0) || ch < 0) {
                return error(buf.toString(), "unterminated string");
            }

            if(ch == '\\'.charCodeAt(0)){
                var err = scanEscape(ch, buf);
                if(err != null){
                    return err;
                }
            } else {
                writeChar(buf, ch);
            }

            ch = next();
        }

        return null;
    }


    function scanEscape(ch:Int, buf:StringBuf):Error {
        ch = next();

        switch ch {
            case 97: {
                buf.addChar(7); // \a
            }
            case 98: {
                buf.addChar(8); // \b
            }
            case 102:{
                buf.addChar(12); // \f
            }
            case 110:{
                buf.add("\n"); // \n
            }
            case 114:{
                buf.add("\r"); // \r
            }
            case 116: {
                buf.add("\t"); // \t
            }
            case 118: {
                buf.addChar(11); // \v
            }
            case 92: {
                buf.add("\\");
            }
            case 34: {
                buf.add('"');
            }
            case 39: {
                buf.add('\'');
            }
            case 10: {
                buf.add("\n");
            }
            case 13: {
                buf.add("\n");
                this.newLine(13);
            }
            default: {
                if (('0'.charCodeAt(0) <= ch) && (ch <= '9'.charCodeAt(0))) {
                    var b = new BytesBuffer();
                    b.addByte(ch);
                    var i = 0;
                    while(i < 2 && isDecimal(peek())) {
                        b.addByte(next());
                        i++;
                    }

                    var val = Std.parseInt(b.getBytes().toString());
                    writeChar(buf, val);

                } else {
                    buf.add("\\");
                    writeChar(buf, ch);
                    return error(buf.toString(), "Invalid escape sequence");
                }
            }
        }

        return null;
    }

    function countSep(ch:Int):{count:Int, char:Int} {
        var count = 0;
        
        while(ch == '='.charCodeAt(0)){
            ch = next();
            count = count + 1;
        }

        return {
            count: count,
            char: ch
        };
    }

    function scanMultilineString(ch:Int, buf:StringBuf):Error {
        var count1:Int, count2:Int;

        var sep:{count:Int, char:Int} = this.countSep(ch);
        ch = sep.char;
        count1 = sep.count;

        if(ch != '['.charCodeAt(0)){
            return error(String.fromCharCode(ch), "invalid multiline string");
        }

        ch = next();
        if (ch == '\n'.charCodeAt(0) || ch == '\r'.charCodeAt(0) ){
            ch = next();
        }  

        while(true){
            if (ch < 0){
                return error(buf.toString(), "unterminated multiline string");
            } else  if(ch == ']'.charCodeAt(0)){
                var sep = countSep(next());
                ch = sep.char;
                count2 = sep.count; 

                if (count1 == count2 && ch == ']'.charCodeAt(0)) {
                    return null;
                }  

                buf.add(']');
                var s:Array<String> = [];
                for(i in 0...(count2-1)){
                    s.push("=");
                }   
                buf.add(s.join(''));
                continue;  
            }

            writeChar(buf, ch);
            ch = next();
        }      

        return null;
    }

    static var reservedWords:StringMap<Types> = [
	"and" => TAnd, "break" => TBreak, "do" => TDo, "else"=> TElse, "elseif"=> TElseIf,
	"end"=> TEnd, "false"=> TFalse, "for"=> TFor, "function"=> TFunction,
	"if"=> TIf, "in"=> TIn, "local"=> TLocal, "nil"=> TNil, "not"=> TNot, "or"=> TOr,
	"return"=> TReturn, "repeat"=> TRepeat, "then"=> TThen, "true"=> TTrue,
	"until"=> TUntil, "while"=> TWhile ];



    /**
     * Scan the lexer and output the token
     * @param lexer 
     * @return Token
     */
    public function scan(lexer:Lexer):{token:Token, err:Error} {
        var tok:Token = new Token({
            type: null,
            str: null,
            pos: null,
            name: null
        });

        var newline = false;
        var err:Error;

        var ch = skipWhiteSpace(Whitespace1);

        if (ch == '\n'.charCodeAt(0) || ch == '\r'.charCodeAt(0)) {
            newline = true;
            ch = skipWhiteSpace(Whitespace2);
        }

        if(ch == '('.charCodeAt(0) && lexer.prevTokenType == ')'.charCodeAt(0)) {
            lexer.pNewLine = newline;
        } else {
            lexer.pNewLine = false;
        }

        var buf = new StringBuf();
        tok.pos = this.pos;

        switch true {

            case isIdent(ch, 0) => r: {
                tok.type = TIdent;
                err = scanIdent(ch, buf);
                tok.str = buf.toString();

                if(err != null){
                    tok.name = Parser.tokenName(tok.type);
                    return {token:tok, err:err};
                }
                
                if(reservedWords.exists(tok.str)){
                    tok.type = reservedWords.get(tok.str);
                }
            }

            case isDecimal(ch) => r: {
                tok.type = TNumber;
                err = scanNumber(ch, buf);
                tok.str = buf.toString();
            }

            default: {
                switch ch {
                    case EOF: {
                        tok.type = EOF;
                    }
                    case 45:{
                        if(peek() == "-".charCodeAt(0)){
                            err = skipComments(next());
                            if(err != null){
                                tok.name = Parser.tokenName(tok.type);
                                return {token:tok, err:err};
                            }

                            return this.scan(lexer);
                        } else {
                            tok.type = ch;
                            tok.str = String.fromCharCode(ch);
                        }
                    }
                    case 34 | 39 : {
                        tok.type = TString;
                        err = scanString(ch, buf);
                        tok.str = buf.toString();
                    }
                    case 91 : {
                        var c = peek();
                        if (c == '['.charCodeAt(0) || c == '='.charCodeAt(0)) {
                            tok.type = TString;
                            err = scanMultilineString(next(), buf);
                            tok.str = buf.toString();
                        } else {
                            tok.type = ch;
                            tok.str = String.fromCharCode(ch);
                        }                        
                    }
                    case 61 : {
                        if (peek() == 61) {
                            tok.type = TEqeq;
                            tok.str = "==";
                            next();
                        } else {
                            tok.type = ch;
                            tok.str = String.fromCharCode(ch);
                        }                        
                    }
                    case 126 : {
                        if (peek() == '='.charCodeAt(0)) {
                            tok.type = TNeq;
                            tok.str = "~=";
                            next();
                        } else {
                            err = error("~", "Invalid '~' token");
                        }
                    }
                    case 60 : {
                        if (peek() == '='.charCodeAt(0)) {
                            tok.type = TLte;
                            tok.str = "<=";
                            next();
                        } else {
                            tok.type = ch;
                            tok.str = String.fromCharCode(ch);
                        }
                    }
                    case 62 : {
                        if (peek() == '='.charCodeAt(0)) {
                            tok.type = TGte;
                            tok.str = ">=";
                            next();
                        } else {
                            tok.type = ch;
                            tok.str = String.fromCharCode(ch);
                        }                        
                    }
                    case 46 : {
                        var ch2 = peek();

                        if (isDecimal(ch2)) {
                            tok.type = TNumber;
                            err = scanNumber(ch, buf);
                            tok.str = buf.toString();                             
                        } else if(ch2 == '.'.charCodeAt(0)){
                            writeChar(buf, ch);
                            writeChar(buf, next());
                            if (peek() == '.'.charCodeAt(0)) {
                                writeChar(buf, next());
                                tok.type = T3Comma;
                            } else {
                                tok.type = T2Comma;
                            }                            
                        } else {
                            tok.type = '.'.charCodeAt(0);
                        }
                        tok.str = buf.toString();
                    }
                    //  '+', '*', '/', '%', '^', '#', '(', ')', '{', '}', ']', ';', ':', ','
                    case 43 | 42 | 47 | 37 | 94 | 35 | 40 | 41 | 123 | 125 | 93 | 59 | 58 | 44 : {
                        tok.type = ch;
                        tok.str = String.fromCharCode(ch);
                    }
                    default: {
                        writeChar(buf, ch);
                        var err = error(buf.toString(), "Invalid token");
                        tok.name = Parser.tokenName(tok.type);
                        return {token:tok, err:err};
                    }
                }
            }
        }
        

        return {token:tok, err:err};
            
    }



}