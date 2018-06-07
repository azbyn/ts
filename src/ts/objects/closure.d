module ts.objects.closure;

import ts.objects.obj;
import ts.ir.block;
import ts.ast.token;
import ts.runtime.env;
import ts.runtime.interpreter;
import ts.misc;

struct Closure {
    Block val;
    Obj*[uint] captures;
    this(Block val, Obj*[uint] captures) {
        this.val = val;
        this.captures = captures;
    }

    Obj opCall(Pos pos, Env env, Obj[] args) {
        return val.eval(pos, env, args, captures);
    }
static:
    TypeMeta typeMeta;
    tsstring type() { return "closure"; }
    tsstring toString(Pos p, Env e, Closure v) {
        tsstring res = "<closure>\n";
        foreach (k, o; v.captures)
            res ~= tsformat!"@%s:%s\n"(k, o.toStr(p, e));
        res ~= "Code:\n"~ v.val.toStr(p, e);
        return res ~ "\n</closure>";
    }
}
