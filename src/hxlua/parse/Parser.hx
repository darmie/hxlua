package hxlua.parse;

import haxe.ds.Vector;
import hxlua.ast.*;

// Lua parser ported by hand from https://github.com/yuin/gopher-lua/parse/parser.go


/**
 * yySymType
 */
typedef YYSymType =  {
	yys:Int,
	token:Token,

	stmts:Array<Stmt>,
	stmt:Stmt,

	funcname:FuncName,
	funcexpr:FunctionExpr,

	exprlist:Array<Expr>,
	expr:Expr,

	fieldlist:Array<Field>,
	field:Field,
	fieldsep:String,

	namelist:Array<String>,
	parlist:ParList
}


interface YYLexer {
    public function lex(lval:YYSymType):Int;
    public function error(s:String):Void;
}

/**
 * Token types
 */
@:enum abstract Types(Int) from Int to Int {
    
    var TAnd = 57346;
    var TBreak = 57347;
    var TDo = 57348;
    var TElse = 57349;
    var TElseIf = 57350;
    var TEnd = 57351;
    var TFalse = 57352;
    var TFor = 57353;
    var TFunction = 57354;
    var TIf = 57355;
    var TIn = 57356;
    var TLocal = 57357;
    var TNil = 57358;
    var TNot = 57359;
    var TOr = 57360;
    var TReturn = 57361;
    var TRepeat = 57362;
    var TThen = 57363;
    var TTrue = 57364;
    var TUntil = 57365;
    var TWhile = 57366;
    var TEqeq = 57367;
    var TNeq = 57368;
    var TLte = 57369;
    var TGte = 57370;
    var T2Comma = 57371;
    var T3Comma = 57372;
    var TIdent = 57373;
    var TNumber = 57374;
    var TString = 57375;
    var UNARY = 57376; 

    @:op(A >= B)
    public static function gteq(a:Types, b:Types):Bool;

}


class Parser {
    static var yyToknames:Array<String> = [
        "TAnd",
        "TBreak",
        "TDo",
        "TElse",
        "TElseIf",
        "TEnd",
        "TFalse",
        "TFor",
        "TFunction",
        "TIf",
        "TIn",
        "TLocal",
        "TNil",
        "TNot",
        "TOr",
        "TReturn",
        "TRepeat",
        "TThen",
        "TTrue",
        "TUntil",
        "TWhile",
        "TEqeq",
        "TNeq",
        "TLte",
        "TGte",
        "T2Comma",
        "T3Comma",
        "TIdent",
        "TNumber",
        "TString",
        " {",
        " (",
        " >",
        " <",
        " +",
        " -",
        " *",
        " /",
        " %",
        "UNARY",
        " ^"
    ];

    static var yyStatenames:Array<String>;

    static var yyEofCode = 1;
    static var yyErrCode = 2;
    static var yyMaxDepth = 200;

    /**
     * get token name from char
     * @param c 
     * @return String
     */
    public static function tokenName(c:Int):String {
        if (c >= TAnd && (c-TAnd < yyToknames.length)){
            if(yyToknames[c-TAnd] != ""){
                return yyToknames[c-TAnd]
            }
        }

        return String.fromCharCode(c);
    }

    static var yyExca:Array<Int> = [
        -1, 1,
        1, -1,
        -2, 0,
        -1, 17,
        46, 31,
        47, 31,
        -2, 68,
        -1, 93,
        46, 32,
        47, 32,
        -2, 68,
    ];

    static var yyNprod = 95;
    static var yyPrivate = 57344;

    static var yyTokenNames:Array<String>;
    static var yyStates:Array<String>;

    static var yyLast = 579;

    static var yyAct = [

        24, 88, 50, 23, 45, 84, 56, 65, 137, 153,
        136, 113, 52, 142, 54, 53, 33, 134, 65, 132,
        62, 63, 32, 61, 108, 109, 48, 111, 106, 41,
        42, 105, 49, 155, 166, 81, 82, 83, 138, 104,
        22, 91, 131, 80, 95, 92, 162, 74, 48, 85,
        150, 99, 165, 148, 49, 149, 75, 76, 77, 78,
        79, 67, 80, 107, 106, 148, 114, 115, 116, 117,
        118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
        128, 129, 72, 73, 71, 70, 74, 65, 39, 40,
        47, 139, 133, 68, 69, 75, 76, 77, 78, 79,
        60, 80, 141, 144, 143, 146, 145, 31, 67, 147,
        9, 48, 110, 97, 48, 152, 151, 49, 38, 62,
        49, 17, 66, 77, 78, 79, 96, 80, 59, 72,
        73, 71, 70, 74, 154, 102, 91, 156, 55, 157,
        68, 69, 75, 76, 77, 78, 79, 21, 80, 187,
        94, 20, 26, 184, 37, 179, 163, 112, 25, 35,
        178, 93, 170, 172, 27, 171, 164, 173, 19, 159,
        175, 174, 29, 89, 28, 39, 40, 20, 182, 181,
        100, 34, 135, 183, 67, 39, 40, 47, 186, 64,
        51, 1, 90, 87, 36, 130, 86, 30, 66, 18,
        46, 44, 43, 8, 58, 72, 73, 71, 70, 74,
        57, 67, 168, 169, 167, 3, 68, 69, 75, 76,
        77, 78, 79, 160, 80, 66, 4, 2, 0, 0,
        0, 158, 72, 73, 71, 70, 74, 0, 0, 0,
        0, 0, 0, 68, 69, 75, 76, 77, 78, 79,
        26, 80, 37, 0, 0, 0, 25, 35, 140, 0,
        0, 0, 27, 0, 0, 0, 0, 0, 0, 0,
        29, 21, 28, 39, 40, 20, 26, 0, 37, 34,
        0, 0, 25, 35, 0, 0, 0, 0, 27, 0,
        0, 0, 36, 98, 0, 0, 29, 89, 28, 39,
        40, 20, 26, 0, 37, 34, 0, 0, 25, 35,
        0, 0, 0, 0, 27, 67, 90, 176, 36, 0,
        0, 0, 29, 21, 28, 39, 40, 20, 0, 66,
        0, 34, 0, 0, 0, 0, 72, 73, 71, 70,
        74, 0, 67, 0, 36, 0, 0, 68, 69, 75,
        76, 77, 78, 79, 0, 80, 66, 0, 177, 0,
        0, 0, 0, 72, 73, 71, 70, 74, 0, 67,
        0, 185, 0, 0, 68, 69, 75, 76, 77, 78,
        79, 0, 80, 66, 0, 161, 0, 0, 0, 0,
        72, 73, 71, 70, 74, 0, 67, 0, 0, 0,
        0, 68, 69, 75, 76, 77, 78, 79, 0, 80,
        66, 0, 0, 180, 0, 0, 0, 72, 73, 71,
        70, 74, 0, 67, 0, 0, 0, 0, 68, 69,
        75, 76, 77, 78, 79, 0, 80, 66, 0, 0,
        103, 0, 0, 0, 72, 73, 71, 70, 74, 0,
        67, 0, 101, 0, 0, 68, 69, 75, 76, 77,
        78, 79, 0, 80, 66, 0, 0, 0, 0, 0,
        0, 72, 73, 71, 70, 74, 0, 67, 0, 0,
        0, 0, 68, 69, 75, 76, 77, 78, 79, 0,
        80, 66, 0, 0, 0, 0, 0, 0, 72, 73,
        71, 70, 74, 0, 0, 0, 0, 0, 0, 68,
        69, 75, 76, 77, 78, 79, 0, 80, 72, 73,
        71, 70, 74, 0, 0, 0, 0, 0, 0, 68,
        69, 75, 76, 77, 78, 79, 0, 80, 7, 10,
        0, 0, 0, 0, 14, 15, 13, 0, 16, 0,
        0, 0, 6, 12, 0, 0, 0, 11, 0, 0,
        0, 0, 0, 0, 21, 0, 0, 0, 20, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 5
    ];


    static var yyPact:Array<Int> = [

        -1000, -1000, 533, -5, -1000, -1000, 292, -1000, -17, 152,
        -1000, 292, -1000, 292, 107, 97, 88, -1000, -1000, -1000,
        292, -1000, -1000, -29, 473, -1000, -1000, -1000, -1000, -1000,
        -1000, 152, -1000, -1000, 292, 292, 292, 14, -1000, -1000,
        142, 292, 116, 292, 95, -1000, 82, 240, -1000, -1000,
        171, -1000, 446, 112, 419, -7, 17, 14, -24, -1000,
        81, -19, -1000, 104, -42, 292, 292, 292, 292, 292,
        292, 292, 292, 292, 292, 292, 292, 292, 292, 292,
        292, -1, -1, -1, -1000, -11, -1000, -37, -1000, -8,
        292, 473, -29, -1000, 152, 207, -1000, 55, -1000, -40,
        -1000, -1000, 292, -1000, 292, 292, 34, -1000, 24, 19,
        14, 292, -1000, -1000, 473, 57, 493, 18, 18, 18,
        18, 18, 18, 18, 83, 83, -1, -1, -1, -1,
        -44, -1000, -1000, -14, -1000, 266, -1000, -1000, 292, 180,
        -1000, -1000, -1000, 160, 473, -1000, 338, 40, -1000, -1000,
        -1000, -1000, -29, -1000, 157, 22, -1000, 473, -12, -1000,
        205, 292, -1000, 154, -1000, -1000, 292, -1000, -1000, 292,
        311, 151, -1000, 473, 146, 392, -1000, 292, -1000, -1000,
        -1000, 144, 365, -1000, -1000, -1000, 140, -1000
    ];

    static var yyPgo:Array<Int> = [

        0, 190, 227, 2, 226, 223, 215, 210, 204, 203,
        118, 6, 3, 0, 22, 107, 168, 199, 4, 197,
        5, 195, 16, 193, 1, 182
    ];

    static var yyR1:Array<Int> = [

        0, 1, 1, 1, 2, 2, 2, 3, 4, 4,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        4, 4, 5, 5, 6, 6, 6, 7, 7, 8,
        8, 9, 9, 10, 10, 10, 11, 11, 12, 12,
        13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
        13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
        13, 13, 13, 13, 13, 13, 13, 14, 15, 15,
        15, 15, 17, 16, 16, 18, 18, 18, 18, 19,
        20, 20, 21, 21, 21, 22, 22, 23, 23, 23,
        24, 24, 24, 25, 25
    ];


    static var yyR2:Array<Int> = [

        0, 1, 2, 3, 0, 2, 2, 1, 3, 1,
        3, 5, 4, 6, 8, 9, 11, 7, 3, 4,
        4, 2, 0, 5, 1, 2, 1, 1, 3, 1,
        3, 1, 3, 1, 4, 3, 1, 3, 1, 3,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 2, 2, 2, 1, 1, 1,
        1, 3, 3, 2, 4, 2, 3, 1, 1, 2,
        5, 4, 1, 1, 3, 2, 3, 1, 3, 2,
        3, 5, 1, 1, 1
    ];

    static var yyChk:Array<Int> = [

        -1000, -1, -2, -6, -4, 45, 19, 5, -9, -15,
        6, 24, 20, 13, 11, 12, 15, -10, -17, -16,
        35, 31, 45, -12, -13, 16, 10, 22, 32, 30,
        -19, -15, -14, -22, 39, 17, 52, 12, -10, 33,
        34, 46, 47, 50, 49, -18, 48, 35, -22, -14,
        -3, -1, -13, -3, -13, 31, -11, -7, -8, 31,
        12, -11, 31, -13, -16, 47, 18, 4, 36, 37,
        28, 27, 25, 26, 29, 38, 39, 40, 41, 42,
        44, -13, -13, -13, -20, 35, 54, -23, -24, 31,
        50, -13, -12, -10, -15, -13, 31, 31, 53, -12,
        9, 6, 23, 21, 46, 14, 47, -20, 48, 49,
        31, 46, 53, 53, -13, -13, -13, -13, -13, -13,
        -13, -13, -13, -13, -13, -13, -13, -13, -13, -13,
        -21, 53, 30, -11, 54, -25, 47, 45, 46, -13,
        51, -18, 53, -3, -13, -3, -13, -12, 31, 31,
        31, -20, -12, 53, -3, 47, -24, -13, 51, 9,
        -5, 47, 6, -3, 9, 30, 46, 9, 7, 8,
        -13, -3, 9, -13, -3, -13, 6, 47, 9, 9,
        21, -3, -13, -3, 9, 6, -3, 9
    ];


    static var yyDef:Array<Int> = [

        4, -2, 1, 2, 5, 6, 24, 26, 0, 9,
        4, 0, 4, 0, 0, 0, 0, -2, 69, 70,
        0, 33, 3, 25, 38, 40, 41, 42, 43, 44,
        45, 46, 47, 48, 0, 0, 0, 0, 68, 67,
        0, 0, 0, 0, 0, 73, 0, 0, 77, 78,
        0, 7, 0, 0, 0, 36, 0, 0, 27, 29,
        0, 21, 36, 0, 70, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 64, 65, 66, 79, 0, 85, 0, 87, 33,
        0, 92, 8, -2, 0, 0, 35, 0, 75, 0,
        10, 4, 0, 4, 0, 0, 0, 18, 0, 0,
        0, 0, 71, 72, 39, 49, 50, 51, 52, 53,
        54, 55, 56, 57, 58, 59, 60, 61, 62, 63,
        0, 4, 82, 83, 86, 89, 93, 94, 0, 0,
        34, 74, 76, 0, 12, 22, 0, 0, 37, 28,
        30, 19, 20, 4, 0, 0, 88, 90, 0, 11,
        0, 0, 4, 0, 81, 84, 0, 13, 4, 0,
        0, 0, 80, 91, 0, 0, 4, 0, 17, 14,
        4, 0, 0, 23, 15, 4, 0, 16
    ];

    static var yyTok1:Array<Int> = [

        1, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 52, 3, 42, 3, 3,
        35, 53, 40, 38, 47, 39, 49, 41, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 48, 45,
        37, 46, 36, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 50, 3, 51, 44, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
        3, 3, 3, 34, 3, 54
    ];

    static var yyTok2:Array<Int> = [

        2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
        22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
        32, 33, 43
    ];


    static var yyTok3:Array<Int> = [
        0
    ];

    static var yyDebug:Int = 0;

    static var yyFlag = -1000;

    private function yyTokname(c:Int):String {
        // 4 is TOKSTART above
        if (c >= 4 && c-4 < yyToknames.length){
            if (yyToknames[c-4] != "") {
                return yyToknames[c-4];
            }
        }

        return 'tok-${c}';
    }

    private function yyStatname(s:Int):String {
        if(s >= 0 && s < yyStatenames.length) {
            if(yyStatenames[s] != ""){
                return yyStatenames[s];
            }
        }

        return 'state-${s}';
    }


    private function yylex1(lex:YYLexer, lval:YYSymType):Int {
        var c = 0;
        var char = lex.lex(lval);

        function out(){
            if (c == 0) {
                c = yyTok2[1]; /* unknown char */
            }
            if (yyDebug >= 3) {
                trace('lex ${yyTokname(c)} ${String.fromCharCode(char)}\n')
            }        
        } 

        if(char <= 0) {
            c = yyTok1[0];
            out();
            return c;
        }
        if (char < yyTok1.length) {
            c = yyTok1[char];
            out();
            return c;
        }
        if (char >= yyPrivate) {
            if (char < yyPrivate+yyTok2.length) {
                c = yyTok2[char-yyPrivate];
                out();
                return c;
            }
        }
        var i = 0;
        while(i < yyTok3.length){
            c = yyTok3[i+0];
            if (c == char) {
                c = yyTok3[i+1];
                out();
                return c;
            }

            i += 2;
        } 

        return c;      
    }



    /**
     * Parse lua
     * @param reader 
     * @param name 
     */
    public function parse(reader:haxe.io.Input, name:String):{ast:Array<hxlua.ast.Stmt>, error:Error} {
        var lexer:Lexer = new Lexer({
            scanner: new Scanner(reader, name),
            stmts: null,
            pNewLine: false,
            token: new Token({
                str: "",
                type: null,
                pos: null,
                name: null
            }),
            prevTokenType: TNil
        });

        var chunk:Array<hxlua.ast.Stmt> = null;
        try {
            yyParse(lexer);
            chunk = lexer.stmts;
        } catch(e:Dynamic){
           return {
                   ast:chunk,
                   error: e
            };
        }

        return {
            ast:chunk,
            error: null
        };
    }


    private function yyParse(yylex:Lexer):Int {
        var yyn:Null<Int> = null;
        var yylval:YYSymType = null;
        var yyVAL:YYSymType = null;
        var yyS:Vector<YYSymType> = new Vector<YYSymType>(yyMaxDepth);

        var Nerrs = 0;   /* number of errors */
        var Errflag = 0; /* error recovery flag */
        var yystate = 0;
        var yychar = -1;
        var yyp = -1;

        //var ret0 = 0;
        var ret;

        // goto's
        var yystack = function (){};
        var yydefault = function (){};
        var yynewstate = function (){};

        yystack = function() {
            /* put a state and value onto the stack */
            if (yyDebug >= 4) {
                trace('char ${yyTokname(yychar)} in ${yyStatname(yystate)}\n');
            }

            yyp++;
            if (yyp >= yyS.length) {
                var nyys:Vector<YYSymType> = new Vector<YYSymType>(yyS.length * 2); //make([]yySymType, len(yyS)*2)
                nyys = yyS.copy();
                yyS = nyys;
            }
            yyS.set(yyp, yyVAL); 
            yyS.get(yyp).yys = yystate;       
        }

        yydefault = function():Void {
            /* default state action */
            yyn = yyDef[yystate];
            if (yyn == -2) {
                if (yychar < 0) {
                    yychar = yylex1(yylex, yylval);
                }

                /* look through exception table */
                var xi = 0;

                while(true){
                    if (yyExca[xi+0] == -1 && yyExca[xi+1] == yystate) {
                        break;
                    }

                    xi += 2;
                }
                xi += 2; 
                while (true){
                    yyn = yyExca[xi+0];
                    if (yyn < 0 || yyn == yychar) {
                        break;
                    }
                    xi += 2;
                }

                yyn = yyExca[xi+1];
                if (yyn < 0) {
                    ret = 0;
                    return;
                }
            }

            if (yyn == 0) {
                /* error ... attempt to resume parsing */
                switch Errflag {
                    case 0: { /* brand new error */
                        yylex.error("syntax error");
                        Nerrs++;
                        if (yyDebug >= 1) {
                            trace('${yyStatname(yystate)}');
                            trace(' saw ${yyTokname(yychar)}\n');
                        }
                    }
                    case 1 | 2 : { /* incompletely recovered error ... try again */
                        Errflag = 3;

                        /* find a state where "error" is a legal shift action */
                        while (yyp >= 0) {
                            yyn = yyPact[yyS.get(yyp).yys] + yyErrCode;
                            if (yyn >= 0 && yyn < yyLast) {
                                yystate = yyAct[yyn]; /* simulate a shift of "error" */
                                if (yyChk[yystate] == yyErrCode) {
                                    /*goto*/ yystack();
                                }
                            }

                            /* the current p has no shift on "error", pop stack */
                            if (yyDebug >= 2) {
                                trace('error recovery pops state ${}\n', yyS.get(yyp).yys);
                            }

                            yyp--;
                        }
                        /* there is no state on the stack with an error shift ... abort */
                        ret = 1;
                        return;
                    }
                    case 3 : { /* no shift yet; clobber input char */
                        if (yyDebug >= 2) {
                            trace('error recovery discards ${yyTokname(yychar)}\n');
                        }

                        if(yychar == yyEofCode){
                            ret = 1;
                            return;
                        }

                        yychar = -1;
                        /*goto*/ yynewstate(); /* try again in the same state */
                    }
                    default: 
                }
            }

            /* reduction by production yyn */
            if(yyDebug >= 2){
                trace('reduce ${yyn} in:\n\t${yyStatname(yystate)}\n');
            } 

            var yynt = yyn;
            var yypt = yyp;

            yyp -= yyR2[yyn];
            yyVAL = yyS.get(yyp+1);

            /* consult goto table to find next state */
            yyn = yyR1[yyn];
            var yyg = yyPgo[yyn];

            var yyj = yyg + yyS.get(yyp).yys + 1;

            if(yyj >= yyLast){
                yystate = yyAct[yyg];
            } else {
                yystate = yyAct[yyj];
                if(yyChk[yystate] != -yyn){
                    yystate = yyAct[yyg];
                }
            }

            // dummy call; replaced with literal code
            switch yynt {
                case 1:{
                    yyVAL.stmts = yyS.get(yypt-0).stmts;
                    if(yylex != null){
                        yylex.stmts = yyVAL.stmts;
                    }
                }
                case 2: {
                    yyVAL.stmts = yyS[yypt-1].stmts;
                    yyVAL.stmts.push(yyS[yypt-0].stmt);
                    if(yylex != null){
                        yylex.stmts = yyVAL.stmts;
                    }                    
                }
                case 3 : {
                    yyVAL.stmts = yyS[yypt-2].stmts;
                    yyVAL.stmts.push(yyS[yypt-1].stmt);
                    if(yylex != null){
                        yylex.stmts = yyVAL.stmts;
                    }                     
                }
                case 4 : {
                    yyVAL.stmts = new Array<Stmt>();
                }
                case 5 : {
                    yyVAL.stmts = yyS[yypt-1].stmts;
                    yyVAL.stmts.push(yyS[yypt-0].stmt);                                     
                }
                case 6 : {
                    yyVAL.stmts = yyS[yypt-1].stmts;
                }
                case 7 : {
                    yyVAL.stmts = yyS[yypt-0].stmts;
                }
                case 8 : {
                    yyVAL.stmt = new AssignStmt();
                    
                    cast(yyVAL.stmt, AssignStmt).lhs = yyS[yypt-2].exprlist;
                    cast(yyVAL.stmt, AssignStmt).rhs = yyS[yypt-0].exprlist;
                    cast(yyVAL.stmt, AssignStmt).setLine(yyS[yypt-2].exprlist[0].line());
                }
                case 9 : {
                    
                    if(!Std.is(yyS[yypt-0].expr, FuncCallExpr)){
                        yylex.error("parse error");
                    } else {
                        yyVAL.stmt = new FuncCallStmt();
                        cast(yyVAL.stmt, FuncCallStmt).expr = yyS[yypt-0].expr;
                    }
                }
                case 10 : {
                    yyVAL.stmt = new DoBlockStmt();
                    cast(yyVAL.stmt, DoBlockStmt).stmts = yyS[yypt-1].stmts;
                    cast(yyVAL.stmt, DoBlockStmt).setLine(yyS[yypt-2].token.pos.line);
                    cast(yyVAL.stmt, DoBlockStmt).setLastLine(yyS[yypt-0].token.pos.line);
                }
                case 11 : {
                    yyVAL.stmt = new WhileStmt();
                    cast(yyVAL.stmt, WhileStmt).condition = yyS[yypt-3].expr;
                    cast(yyVAL.stmt, WhileStmt).stmts = yyS[yypt-1].stmts;
                    cast(yyVAL.stmt, WhileStmt).setLine(yyS[yypt-4].token.pos.line);
                    cast(yyVAL.stmt, WhileStmt).setLastLine(yyS[yypt-0].token.pos.line);
                }
                case 12 : {
                    yyVAL.stmt = new RepeatStmt();
                    cast(yyVAL.stmt, RepeatStmt).condition = yyS[yypt-0].expr;
                    cast(yyVAL.stmt, RepeatStmt).stmts = yyS[yypt-2].stmts;
                    cast(yyVAL.stmt, RepeatStmt).setLine(yyS[yypt-3].token.pos.line);
                    cast(yyVAL.stmt, RepeatStmt).setLastLine(yyS[yypt-0].expr.line());
                }
                case 13 : {
                    yyVAL.stmt = new IfStmt();
                    cast(yyVAL.stmt, IfStmt).condition = yyS[yypt-4].expr;
                    cast(yyVAL.stmt, IfStmt).then = yyS[yypt-2].stmts;
                    
                    var cur:IfStmt = cast(yyVAL.stmt, IfStmt);
                    for (elseif in yyS[yypt-1].stmts) {
                        cur.Else = [cast(elseif, IfStmt)];
                        cur = cast(elseif, IfStmt);
                    }
                    cast(yyVAL.stmt, IfStmt).setLine(yyS[yypt-5].token.pos.line);
                    cast(yyVAL.stmt, IfStmt).setLastLine(yyS[yypt-0].token.pos.line);                  
                }
                case 14 : {
                    yyVAL.stmt = new IfStmt();
                    cast(yyVAL.stmt, IfStmt).condition = yyS[yypt-6].expr;
                    cast(yyVAL.stmt, IfStmt).then = yyS[yypt-4].stmts;
                    
                    var cur:IfStmt = cast(yyVAL.stmt, IfStmt);
                    for (elseif in yyS[yypt-3].stmts) {
                        cur.Else = [cast(elseif, IfStmt)];
                        cur = cast(elseif, IfStmt);
                    }
                    cur.Else = yyS[yypt-1].stmts;
                    cast(yyVAL.stmt, IfStmt).setLine(yyS[yypt-7].token.pos.line)
                    cast(yyVAL.stmt, IfStmt).setLastLine(yyS[yypt-0].token.pos.line)                    
                }
                case 15 : {
                    yyVAL.stmt = new NumberForStmt();
                    //{Name: yyS[yypt-7].token.Str, Init: yyS[yypt-5].expr, Limit: yyS[yypt-3].expr, Stmts: yyS[yypt-1].stmts}
                    cast(yyVAL.stmt, NumberForStmt).name = yyS[yypt-7].token.str;
                    cast(yyVAL.stmt, NumberForStmt).init = yyS[yypt-5].expr;
                    cast(yyVAL.stmt, NumberForStmt).limit = yyS[yypt-3].expr;
                    cast(yyVAL.stmt, NumberForStmt).stmts = yyS[yypt-1].stmts;

                    cast(yyVAL.stmt, IfStmt).setLine(yyS[yypt-8].token.pos.line)
                    cast(yyVAL.stmt, IfStmt).setLastLine(yyS[yypt-0].token.pos.line)                     
                }
                case 16 : {
                    yyVAL.stmt = new NumberForStmt();
                    
                    cast(yyVAL.stmt, NumberForStmt).name = yyS[yypt-9].token.str;
                    cast(yyVAL.stmt, NumberForStmt).init = yyS[yypt-7].expr;
                    cast(yyVAL.stmt, NumberForStmt).limit = yyS[yypt-5].expr;
                    cast(yyVAL.stmt, NumberForStmt).step = yyS[yypt-3].expr;
                    cast(yyVAL.stmt, NumberForStmt).stmts = yyS[yypt-1].stmts;

                    cast(yyVAL.stmt, IfStmt).setLine(yyS[yypt-10].token.pos.line);
                    cast(yyVAL.stmt, IfStmt).setLastLine(yyS[yypt-0].token.pos.line)                     
                }
                case 17 : {
                    yyVAL.stmt = new GenericForStmt();
                    //Names: yyS[yypt-5].namelist, Exprs: yyS[yypt-3].exprlist, Stmts: yyS[yypt-1].stmts
                    cast(yyVAL.stmt, GenericForStmt).names = yyS[yypt-5].namelist;
                    cast(yyVAL.stmt, GenericForStmt).exprs = yyS[yypt-3].exprlist;
                    cast(yyVAL.stmt, GenericForStmt).stmts = yyS[yypt-1].stmts;

                    cast(yyVAL.stmt, GenericForStmt).setLine(yyS[yypt-6].token.pos.line);
                    cast(yyVAL.stmt, GenericForStmt).setLastLine(yyS[yypt-0].token.pos.line);
                }
                case 18 : {
                    yyVAL.stmt = new FuncDefStmt();
                    cast(yyVAL.stmt, FuncDefStmt).name = yyS[yypt-1].funcname;
                    cast(yyVAL.stmt, FuncDefStmt).func = yyS[yypt-0].funcexpr;

                    cast(yyVAL.stmt, FuncDefStmt).setLine(yyS[yypt-2].token.pos.line);
                    cast(yyVAL.stmt, FuncDefStmt).setLastLine(yyS[yypt-0].funcexpr.lastLine());                  
                                      
                }
                case 19 : {
                    yyVAL.stmt = new LocalAssignStmt();
                    cast(yyVAL.stmt, LocalAssignStmt).names = [yyS[yypt-1].token.str];
                    cast(yyVAL.stmt, LocalAssignStmt).exprs = [yyS[yypt-0].funcexpr];

                    cast(yyVAL.stmt, LocalAssignStmt).setLine(yyS[yypt-3].token.pos.line);
                    cast(yyVAL.stmt, LocalAssignStmt).setLastLine(yyS[yypt-0].funcexpr.lastLine());
                }
                case 20 : {
                    yyVAL.stmt = new LocalAssignStmt();
                    //{Names: yyS[yypt-2].namelist, Exprs: yyS[yypt-0].exprlist}
                    cast(yyVAL.stmt, LocalAssignStmt).names = [yyS[yypt-2].token.str];
                    cast(yyVAL.stmt, LocalAssignStmt).exprs = yyS[yypt-0].exprlist;

                    cast(yyVAL.stmt, LocalAssignStmt).setLine(yyS[yypt-3].token.pos.line);
                }
                case 21 : {
                    yyVAL.stmt = new LocalAssignStmt();
                    //{Names: yyS[yypt-2].namelist, Exprs: yyS[yypt-0].exprlist}
                    cast(yyVAL.stmt, LocalAssignStmt).names = yyS[yypt-0].namelist;
                    cast(yyVAL.stmt, LocalAssignStmt).exprs = new Array<Expr>();
                    
                    cast(yyVAL.stmt, LocalAssignStmt).setLine(yyS[yypt-1].token.pos.line);
                }
                case 22 : {
                    yyVAL.stmts = new Array<Stmt>();
                }
                case 23 : {
                    yyVAL.stmts = yyS[yypt-4].stmts;
                    var _ifStmt = new IfStmt();
                    _ifStmt.condition = yyS[yypt-2].expr;
                    _ifStmt.then = yyS[yypt-0].stmts;

                    yyVAL.stmts.push(_ifStmt);

                    cast(yyVAL.stmts[yyVAL.stmts.length-1], IfStmt).setLine(yyS[yypt-3].token.pos.line);
                }
                case 24 : {
                    yyVAL.stmt = new ReturnStmt();
                    cast(yyVAL.stmt, ReturnStmt).exprs = null;
                    cast(yyVAL.stmt, ReturnStmt).setLine(yyS[yypt-0].token.pos.line);                 
                }
                case 25 : {
                    yyVAL.stmt = new ReturnStmt();
                    cast(yyVAL.stmt, ReturnStmt).exprs = yyS[yypt-0].exprlist;
                    cast(yyVAL.stmt, ReturnStmt).setLine(yyS[yypt-1].token.pos.line); 
                }
                case 26 : {
                    yyVAL.stmt = new BreakStmt();
                    cast(yyVAL.stmt, BreakStmt).setLine(yyS[yypt-0].token.pos.line); 
                }
                case 27 : {
                    yyVAL.funcname = yyS[yypt-0].funcname;
                }
                case 28 : {
                    yyVAL.funcname = {func: null, receiver: yyS[yypt-2].funcname.func, method: yyS[yypt-0].token.str};
                }
                case 29 : {
                    var _ident:IdentExpr = new IdentExpr();
                    _ident.value =  yyS[yypt-0].token.str;
                    yyVAL.funcname = {func: _ident, receiver: null, method: null};
                }
                case 30 : {
                    var key = new StringExpr();
                    key.value = yyS[yypt-0].token.str;
                    key.setLine(yyS[yypt-0].token.pos.line);
                    var fn = new AttrGetExpr();
                    fn.object = yyS[yypt-2].funcname.func;
                    fn.key = key;
                    fn.setLine(yyS[yypt-0].token.pos.line);
                    yyVAL.funcname = {func: fn, receiver: null, method: null};
                }
                case 31 : {
                    yyVAL.exprlist = [yyS[yypt-0].expr]; 
                }
                case 32 : {
                    yyVAL.exprlist = yyS[yypt-2].exprlist;
                    yyVAL.exprlist.push(yyS[yypt-0].expr);
                }
                case 33 : {
                    yyVAL.expr = new IdentExpr();
                    cast(yyVAL.expr, IdentExpr).value = yyS[yypt-0].token.str;
                    cast(yyVAL.expr, IdentExpr).setLine(yyS[yypt-0].token.pos.line);
                }
                case 34 : {
                    yyVAL.expr = new AttrGetExpr();
                    cast(yyVAL.expr, AttrGetExpr).object = yyS[yypt-3].expr;
                    cast(yyVAL.expr, AttrGetExpr).key = yyS[yypt-1].expr;
                    cast(yyVAL.expr, AttrGetExpr).setLine(yyS[yypt-3].expr.line());
                }
                case 35 : {
                    var key = new StringExpr();
                    key.value = yyS[yypt-0].token.str;
                    key.setLine(yyS[yypt-0].token.pos.line);
                    yyVAL.expr = new AttrGetExpr();
                    cast(yyVAL.expr, AttrGetExpr).object = yyS[yypt-2].expr;
                    cast(yyVAL.expr, AttrGetExpr).key = key;
                    cast(yyVAL.expr, AttrGetExpr).setLine(yyS[yypt-2].expr.line());                    
                }
                case 36 : {
                    yyVAL.namelist = [yyS[yypt-0].token.str];
                }
                case 37 : {
                    yyVAL.namelist = yyS[yypt-2].namelist;
                    yyVAL.namelist.push(yyS[yypt-0].token.str);
                }
                case 38 : {
                    yyVAL.exprlist = [yyS[yypt-0].expr];
                }
                case 39 : {
                    yyVAL.exprlist = yyS[yypt-2].exprlist;
                    yyVAL.exprlist.push(yyS[yypt-0].expr);
                }
                case 40 : {
                    yyVAL.expr = new NilExpr();
                    yyVAL.expr.setLine(yyS[yypt-0].token.pos.line);
                }
                case 41 : {
                    yyVAL.expr = new FalseExpr();
                    yyVAL.expr.setLine(yyS[yypt-0].token.pos.line);
                }
                case 42 : {
                    yyVAL.expr = new TrueExpr();
                    yyVAL.expr.setLine(yyS[yypt-0].token.pos.line);
                }
                case 43 : {
                    yyVAL.expr = new NumberExpr();
                    cast(yyVAL.expr, NumberExpr).value = yyS[yypt-0].token.str;
                }
                case 44 : {
                    yyVAL.expr = new Comma3Expr();
                    yyVAL.expr.setLine(yyS[yypt-0].token.pos.line);
                }
                case 45 : {
                    yyVAL.expr = yyS[yypt-0].expr;
                }
                case 46 : {
                    yyVAL.expr = yyS[yypt-0].expr;
                }
                case 47 : {
                    yyVAL.expr = yyS[yypt-0].expr;
                }
                case 48 : {
                    yyVAL.expr = yyS[yypt-0].expr;
                }
                case 49 : {
                    yyVAL.expr = new LogicalOpExpr();
                    cast(yyVAL.expr, LogicalOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, LogicalOpExpr).operator = "or";
                    cast(yyVAL.expr, LogicalOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, LogicalOpExpr).setLine(yyS[yypt-2].expr.line());
                }
                case 50 : {
                    yyVAL.expr = new LogicalOpExpr();
                    cast(yyVAL.expr, LogicalOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, LogicalOpExpr).operator = "and";
                    cast(yyVAL.expr, LogicalOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, LogicalOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }
                case 51 : {
                    yyVAL.expr = new RelationalOpExpr();
                    cast(yyVAL.expr, RelationalOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, RelationalOpExpr).operator = ">";
                    cast(yyVAL.expr, RelationalOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, RelationalOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }
                case 52 : {
                    yyVAL.expr = new RelationalOpExpr();
                    cast(yyVAL.expr, RelationalOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, RelationalOpExpr).operator = "<";
                    cast(yyVAL.expr, RelationalOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, RelationalOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }
                case 53 : {
                    yyVAL.expr = new RelationalOpExpr();
                    cast(yyVAL.expr, RelationalOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, RelationalOpExpr).operator = ">=";
                    cast(yyVAL.expr, RelationalOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, RelationalOpExpr).setLine(yyS[yypt-2].expr.line());                   
                } 
                case 54 : {
                    yyVAL.expr = new RelationalOpExpr();
                    cast(yyVAL.expr, RelationalOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, RelationalOpExpr).operator = "<=";
                    cast(yyVAL.expr, RelationalOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, RelationalOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }
                case 55 : {
                    yyVAL.expr = new RelationalOpExpr();
                    cast(yyVAL.expr, RelationalOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, RelationalOpExpr).operator = "==";
                    cast(yyVAL.expr, RelationalOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, RelationalOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }  
                case 56 : {
                    yyVAL.expr = new RelationalOpExpr();
                    cast(yyVAL.expr, RelationalOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, RelationalOpExpr).operator = "~=";
                    cast(yyVAL.expr, RelationalOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, RelationalOpExpr).setLine(yyS[yypt-2].expr.line());                   
                } 
                case 57 : {
                    yyVAL.expr = new StringConcatOpExpr();
                    cast(yyVAL.expr, StringConcatOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, StringConcatOpExpr).rhs = yyS[yypt-0].expr;
                } 
                case 58 : {
                    yyVAL.expr = new ArithmeticOpExpr();
                    cast(yyVAL.expr, ArithmeticOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).operator = "+";
                    cast(yyVAL.expr, ArithmeticOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }  
                case 59 : {
                    yyVAL.expr = new ArithmeticOpExpr();
                    cast(yyVAL.expr, ArithmeticOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).operator = "-";
                    cast(yyVAL.expr, ArithmeticOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).setLine(yyS[yypt-2].expr.line());                   
                } 
                case 60 : {
                    yyVAL.expr = new ArithmeticOpExpr();
                    cast(yyVAL.expr, ArithmeticOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).operator = "*";
                    cast(yyVAL.expr, ArithmeticOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).setLine(yyS[yypt-2].expr.line());                   
                } 
                case 61 : {
                    yyVAL.expr = new ArithmeticOpExpr();
                    cast(yyVAL.expr, ArithmeticOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).operator = "/";
                    cast(yyVAL.expr, ArithmeticOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }
                case 62 : {
                    yyVAL.expr = new ArithmeticOpExpr();
                    cast(yyVAL.expr, ArithmeticOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).operator = "%";
                    cast(yyVAL.expr, ArithmeticOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }
                case 63 : {
                    yyVAL.expr = new ArithmeticOpExpr();
                    cast(yyVAL.expr, ArithmeticOpExpr).lhs = yyS[yypt-2].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).operator = "^";
                    cast(yyVAL.expr, ArithmeticOpExpr).rhs = yyS[yypt-0].expr;
                    cast(yyVAL.expr, ArithmeticOpExpr).setLine(yyS[yypt-2].expr.line());                   
                }
                case 64 : {
                    yyVAL.expr = new UnaryMinusOpExpr();
                    cast(yyVAL.expr, UnaryMinusOpExpr).expr = yyS[yypt-0].expr;
                    cast(yyVAL.expr, UnaryMinusOpExpr).setLine(yyS[yypt-0].expr.line());
                }
                case 65 : {
                    yyVAL.expr = new UnaryNotOpExpr();
                    cast(yyVAL.expr, UnaryNotOpExpr).expr = yyS[yypt-0].expr;
                    cast(yyVAL.expr, UnaryNotOpExpr).setLine(yyS[yypt-0].expr.line());
                } 
                case 66 : {
                    yyVAL.expr = new UnaryLenOpExpr();
                    cast(yyVAL.expr, UnaryLenOpExpr).expr = yyS[yypt-0].expr;
                    cast(yyVAL.expr, UnaryLenOpExpr).setLine(yyS[yypt-0].expr.line());
                } 
                case 67 : {
                    yyVAL.expr = new StringExpr();
                    cast(yyVAL.expr, StringExpr).value =  yyS[yypt-0].token.str;
                }
                case 68 : {
                    yyVAL.expr = yyS[yypt-0].expr;
                } 
                case 69 : {
                    yyVAL.expr = yyS[yypt-0].expr;
                }
                case 70 : {
                    yyVAL.expr = yyS[yypt-0].expr;
                }   
                case 71 : {
                    yyVAL.expr = yyS[yypt-1].expr;
                    yyVAL.expr.setLine(yyS[yypt-2].token.pos.line);
                }
                case 72 : {
                    cast(yyS[yypt-1].expr, FuncCallExpr).adjustRet = true;
                    yyVAL.expr = yyS[yypt-1].expr;
                } 
                case 73 : {
                    yyVAL.expr = new FuncCallExpr();
                    cast(yyVAL.expr, FuncCallExpr).func = yyS[yypt-1].expr;
                    cast(yyVAL.expr, FuncCallExpr).args = yyS[yypt-0].exprlist;
                    cast(yyVAL.expr, FuncCallExpr).setLine(yyS[yypt-1].expr.line());
                } 
                case 74 : {
                    yyVAL.expr = new FuncCallExpr();
                    cast(yyVAL.expr, FuncCallExpr).method = yyS[yypt-1].token.str;
                    cast(yyVAL.expr, FuncCallExpr).receiver = yyS[yypt-3].expr;
                    cast(yyVAL.expr, FuncCallExpr).args = yyS[yypt-0].exprlist;
                    cast(yyVAL.expr, FuncCallExpr).setLine(yyS[yypt-3].expr.line());
                } 
                case 75 : {
                    if (yylex.pNewLine) {
                        yylex.tokenError(yyS[yypt-1].token, "ambiguous syntax (function call x new statement)");
                    }
                    yyVAL.exprlist = new Array<Expr>();
                }
                case 76 : {
                    if(yylex.pNewLine){
                        yylex.tokenError(yyS[yypt-2].token, "ambiguous syntax (function call x new statement)");
                    }
                    yyVAL.exprlist = yyS[yypt-1].exprlist;
                }
                case 77 : {
                    yyVAL.exprlist = [yyS[yypt-0].expr];
                }
                case 78 : {
                    yyVAL.exprlist = [yyS[yypt-0].expr];
                }
                case 79 : {
                    yyVAL.expr = new FunctionExpr();
                    cast(yyVAL.expr, FunctionExpr).parList = yyS[yypt-0].funcexpr.parList;
                    cast(yyVAL.expr, FunctionExpr).stmts = yyS[yypt-0].funcexpr.stmts;
                    cast(yyVAL.expr, FunctionExpr).setLine(yyS[yypt-1].token.pos.line);
                    cast(yyVAL.expr, FunctionExpr).setLastLine(yyS[yypt-0].funcexpr.lastLine());
                }
                case 80 : {
                    yyVAL.funcexpr = new FunctionExpr();
                    cast(yyVAL.expr, FunctionExpr).parList = yyS[yypt-3].parlist;
                    cast(yyVAL.expr, FunctionExpr).stmts = yyS[yypt-1].stmts;
                    cast(yyVAL.expr, FunctionExpr).setLine(yyS[yypt-4].token.pos.line);
                    cast(yyVAL.expr, FunctionExpr).setLastLine(yyS[yypt-0].funcexpr.lastLine());
                }
                case 81 : {
                    yyVAL.funcexpr = new FunctionExpr();
                    cast(yyVAL.expr, FunctionExpr).parList = {hasVargs: false, names: new Array<String>()};
                    cast(yyVAL.expr, FunctionExpr).stmts = yyS[yypt-1].stmts;
                    cast(yyVAL.expr, FunctionExpr).setLine(yyS[yypt-3].token.pos.line);
                    cast(yyVAL.expr, FunctionExpr).setLastLine(yyS[yypt-0].funcexpr.lastLine());
                }
                case 82 : {
                    yyVAL.parlist = {hasVargs: true, names: new Array<String>()};
                }
                case 83 : {
                    yyVAL.parlist = {hasVargs: false, names: new Array<String>()};
                    yyVAL.parlist.names = yyVAL.parlist.names.concat(yyS[yypt-0].namelist);
                }
                case 84 : {
                    yyVAL.parlist = {hasVargs: true, names: new Array<String>()};
                    yyVAL.parlist.names = yyVAL.parlist.names.concat(yyS[yypt-2].namelist);
                } 
                case 85 : {
                    yyVAL.expr = new TableExpr();
                    cast(yyVAL.expr, TableExpr).fields = [];
                    cast(yyVAL.expr, TableExpr).setLine(yyS[yypt-1].token.pos.line);
                }
                case 86 : {
                    yyVAL.expr = new TableExpr();
                    cast(yyVAL.expr, TableExpr).fields = yyS[yypt-1].fieldlist;
                    cast(yyVAL.expr, TableExpr).setLine(yyS[yypt-2].token.pos.line);                   
                }  
                case 87 : {
                    yyVAL.fieldlist = new Array<Field>();
                    yyVAL.fieldlist.push(yyS[yypt-0].field);
                }
                case 88 : {
                    yyVAL.fieldlist = yyS[yypt-2].fieldlist;
                    yyVAL.fieldlist.push(yyS[yypt-0].field);
                }
                case 89 : {
                    yyVAL.fieldlist = yyS[yypt-1].fieldlist;
                } 
                case 90 : {
                    var _strExpr = new StringExpr();
                    _strExpr.value =  yyS[yypt-2].token.str;
                    yyVAL.field = {key: _strExpr, value: yyS[yypt-0].expr};
                    yyVAL.field.key.setLine(yyS[yypt-2].token.pos.line);
                } 
                case 91 : {
                    yyVAL.field = {key: yyS[yypt-3].expr, value: yyS[yypt-0].expr};
                } 
                case 92 : {
                    yyVAL.field = {key:null, value: yyS[yypt-0].expr};
                } 
                case 93 : {
                    yyVAL.fieldsep = ",";
                }
                case 94 : {
                    yyVAL.fieldsep = ";";
                }       
            }
           /*goto*/ yystack();
        }

        yynewstate = function():Void {
            yyn = yyPact[yystate];
            if (yyn <= yyFlag) {
                /*goto*/ yydefault(); /* simple state */
            }
            if (yychar < 0) {
                yychar = yylex1(yylex, yylval);
            }
            yyn += yychar;
            if (yyn < 0 || yyn >= yyLast) {
                /*goto*/ yydefault();
            }
            yyn = yyAct[yyn];
            if (yyChk[yyn] == yychar) { /* valid shift */
                yychar = -1;
                yyVAL = yylval;
                yystate = yyn;
                if (Errflag > 0) {
                    Errflag--;
                }
                /*goto*/ yystack();
            }
        }

        yystack();

        return ret;
    }
}