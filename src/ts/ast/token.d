module ts.ast.token;

import com.str;

alias Pos = int;

alias TT = Token.Type;

extern(C++) int foo () {
    import stdd.variant;
    import stdd.format;

    Variant v;
    auto a = format!"here %s"("ja");
    return cast(int) a.length;
}

private struct TypeData {
    string typeName;
    string symbolicStr;
    string functionName;
}

//dfmt off
private enum typeDatas = [
    //      typeName,     symbolicStr, functionName
    TypeData("eof",          "EOF",       ""         ),//only used by parser
    TypeData("newLine",      "NL",        ""         ),
    TypeData("terminator",   ";",         ""         ),
    TypeData("comma",        ",",         ""         ),
    TypeData("true_",        "true",      ""         ),
    TypeData("false_",       "false",     ""         ),
    TypeData("nil",          "nil",       ""         ),
    TypeData("fun",          "fun",       ""         ),
    TypeData("if_",          "if",        ""         ),
    TypeData("else_",        "else",      ""         ),
    TypeData("break_",       "break",     ""         ),
    TypeData("continue_",    "continue",  ""         ),
    TypeData("while_",       "while",     ""         ),
    TypeData("for_",         "for",       ""         ),
    TypeData("in_",          "in",        ""         ),
    TypeData("return_",      "return ",   ""         ),
    TypeData("identifier",   "id",        ""         ),
    TypeData("number",       "num",       ""         ),
    TypeData("string",       "str",       ""         ),
    TypeData("lambda",       "λ",         ""         ),
    TypeData("arrow",        "->",        ""         ),
    TypeData("lParen",       "(",         ""         ),
    TypeData("rParen",       ")",         ""         ),
    TypeData("lSquare",      "[",         ""         ),
    TypeData("rSquare",      "]",         ""         ),
    TypeData("lCurly",       "{",         ""         ),
    TypeData("rCurly",       "}",         ""         ),
    TypeData("dot",          ".",         ""         ),
    TypeData("inc",          "++",        "opInc"    ),
    TypeData("dec",          "--",        "opDec"    ),
    TypeData("plus",         "+",         "opAdd"    ),
    TypeData("minus",        "-",         "opSub"    ),
    TypeData("mply",         "*",         "opMply"   ),
    TypeData("div",          "/",         "opDiv"    ),
    TypeData("intDiv",       "//",        "opIntdiv" ),
    TypeData("mod",          "%",         "opMod"    ),
    TypeData("pow",          "**",        "opPow"    ),
    TypeData("eq",           "==",        "opEq"     ),
    TypeData("ne",           "!=",        ""         ),
    TypeData("lt",           "<",         ""         ),
    TypeData("gt",           ">",         ""         ),
    TypeData("le",           "<=",        ""         ),
    TypeData("ge",           ">=",        ""         ),
    TypeData("and",          "&&",        ""         ),
    TypeData("or",           "||",        ""         ),
    TypeData("not",          "!",         "opNot"    ),
    TypeData("xor",          "^",         "opXor"    ),
    TypeData("bAnd",         "&",         "opAnd"    ),
    TypeData("bOr",          "|",         "opOr"     ),
    TypeData("lsh",          "<<",        "opLsh"    ),
    TypeData("rsh",          ">>",        "opRsh"    ),
    TypeData("tilde",        "~",         "opCat"    ),
    TypeData("assign",       "=",         ""         ),
    TypeData("question",     "?",         ""         ),
    TypeData("colon",        ":",         ""         ),
    TypeData("catEq",        "~=",        "opCat"    ),
    TypeData("plusEq",       "+=",        "opAdd"    ),
    TypeData("minusEq",      "-=",        "opSub"    ),
    TypeData("mplyEq",       "*=",        "opMply"   ),
    TypeData("divEq",        "/=",        "opDiv"    ),
    TypeData("intDivEq",     "//=",       "opIntdiv" ),
    TypeData("modEq",        "%=",        "opMod"    ),
    TypeData("powEq",        "**=",       "opPow"    ),
    TypeData("lshEq",        "<<=",       "opLsh"    ),
    TypeData("rshEq",        ">>=",       "opRsh"    ),
    TypeData("andEq",        "&=",        "opAnd"    ),
    TypeData("xorEq",        "^=",        "opXor"    ),
    TypeData("orEq",         "|=",        "opOr"     ),
];
//dfmt on

extern(C++)
struct Token {
    private static string _genType() {
        auto result = "enum Type {";
        static foreach (a; typeDatas)
            result ~= a.typeName ~ ", ";
        return result ~ "}";
    }
    mixin(_genType());

    Type type;
    Str val;

}

/*
static foreach (a; typeDatas)
    mixin(format!`Token tok_%s(string s = ""){ return Token(TT.%s, s); }`(
              ((s)=>s[$-1]=='_'? s[0..$-1] : s)(a.typeName), a.typeName));
*/
/+
string binaryFunctionName(TT type) {
    final switch (type) {
        static foreach (a; typeDatas)
            mixin(format!`case TT.%s: return "%s";`(a.typeName, a.functionName));
    }
}
string unaryFunctionName(TT type) {
    switch (type) {
        // dfmt off
    case TT.plus: return "opPlus";
    case TT.minus: return "opMinus";
    case TT.inc: return "opInc";
    case TT.dec: return "opDec";
    case TT.not: return "opNot";
    case TT.tilde: return "opCom";
    default: assert(0);
        // dfmt on
    }
}
string symbolicStr(TT type) {
    final switch (type) {
        static foreach (a; typeDatas) {
            mixin(format!`case TT.%s: return "%s";`(a.typeName, a.symbolicStr));
        }
    }
}
string symbolicToTTName(string symbolic) {
    final switch (symbolic) {
        static foreach (a; typeDatas) {
            mixin(format!r"case `%s`: return `%s`;"(a.symbolicStr, a.typeName));
        }
    }
}
static TT symbolicToTT(string t) {
        switch (t) {
            static foreach (a; typeDatas)
                mixin(format!r"case `%s`: return TT.%s;"(a.symbolicStr, a.typeName));
        default:
            assert(0, format!"invalid type '%s'"(t));
        }
    }
    +/
/*

extern(C++, ts):
struct Token {
    private static string _genType() {
        auto result = "enum Type {";
        static foreach (a; typeDatas)
            result ~= a.typeName ~ ", ";
        return result ~ "}";
    }
    mixin(_genType());


    Type type;
    const(char)* val;
    this(Type type, const(char)* val = "") {
        this.type = type;
        this.val = val;
    }
    /*
    private this(string t, const(char*) val = "") {
        this.type = symbolicToType(t);
        this.val = val;

    }* /
    const(char)* toString() {
        switch (type) {
            static foreach (a; typeDatas) {
                mixin(format!`case Type.%s:`(a.typeName));
                return a.editorRepr(val);
            }
            default:
            assert(0);
        }

    }
    //imm string val;
    /*

    this(Type type, immutable(char)[] val="") {
        this.type = type;
        this.val = val;
    }
    private this(string t, string val="") {
        this.type = symbolicToType(t);
        this.val = val;
    }
    immutable(char)[] c_str() {
        return val;
    }
    string toString() {
        switch (type) {
            static foreach (a; typeDatas) {
                mixin(format!`case Type.%s:`(a.typeName));
                return a.editorRepr(val);
            }
            default:
            assert(0);
        }
    }


    static Type symbolicToType(string t) {
        switch (t) {
            static foreach (a; typeDatas)
                mixin(format!r"case `%s`: return Type.%s;"(a.symbolicStr, a.typeName));
        default:
            assert(0, format!"invalid type '%s'"(t));
        }
    }
* /
}
/*
static foreach (a; typeDatas)
    mixin(format!`Token tok_%s(string s = ""){ return Token(Token.Type.%s, s); }`(
              ((s)=>s[$-1]=='_'? s[0..$-1] : s)(a.typeName), a.typeName));


unittest {
    assert(tok_string("hello").toString() == `"hello"`);
    assert(tok_rsh().type.binaryFunctionName == "opRsh");
    enum t = tok_plus();
    assert(t.type.unaryFunctionName == "opPlus");
    assert(t.type.binaryFunctionName == "opAdd");
    }*/
