module ts.objects.function_;

import ts.objects.obj;
import ts.ir.block;
import ts.ast.token;
import ts.runtime.env;
import ts.runtime.interpreter;
import ts.misc;

struct Function {
    Block val;
    this(Block val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] args) {
        return val.eval(pos, env, args);
    }
    static tsstring toString(Function v) { return tsformat!"\n<function>%s\n</function>"(v.val); }
    static tsstring type() { return "function"; }
}