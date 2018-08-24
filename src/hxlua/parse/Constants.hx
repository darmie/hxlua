package hxlua.parse;

enum abstract Constants(Int) from Int to Int {
    var EOF = -1;
    var Whitespace1 = 1<<9 | 1<<32;
    var Whitespace2 = 1<<9 | 1<<10 | 1<<13 | 1<<32;

    @:op(A == B)
    public static function (a:Constants, b:Constants):Bool;
}