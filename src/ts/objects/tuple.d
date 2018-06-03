module ts.objects.tuple;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv;
import stdd.format;
import stdd.array;

private alias Tuple = Tuple_;
struct Tuple_ {
    Obj[] val;
    this(Obj[] val) {
        this.val = val;
    }
static:
    void ctor(Tuple* v) { v.val = []; }
    void ctor(Tuple* v, Tuple o) {
        v.val = o.val;
    }
    tsstring toString(Tuple v) {
        tsstring res = "(";
        foreach (o; v.val)
            res ~= o.toStr() ~", ";
        return res ~ ")";
    }
    tsstring type() { return "tuple"; }
    tsint PropSet_Test(Tuple* t, tsint i) {
        import com.log;
        tslog("<TEST");
        t.val[0] = objInt(i);
        return i;
    }

    tsint Size(Tuple v) { return v.val.length; }
    Obj opIndex(Pos pos, Tuple v, tsint i) {
        return v.val[i];
    }

    Obj Head(Tuple t) { return t.val[0]; }
    Tuple Tail(Tuple t) { return Tuple(t.val[1..$]); }

    bool toBool(Tuple v) { return v.val.length != 0; }
    TupleIter Iter(Tuple v) { return TupleIter(v); }
}
struct TupleIter {
    Obj* beg;
    Obj* end;
    Obj* ptr;
    this(Tuple l) {
        beg = ptr = l.val.ptr;
        end = beg + l.val.length;
    }
static:
    tsstring type() { return "tuple_iterator"; }
    TupleIter Iter(TupleIter v) { return v; }
    Obj  Val(TupleIter v) { return *v.ptr; }
    tsint Index(TupleIter v) { return v.ptr-v.beg; }
    bool next(TupleIter* v) { return ++v.ptr < v.end; }
}
