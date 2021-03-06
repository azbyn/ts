module mos.objects.range;

import mos.objects.obj;
import mos.stdlib;

mixin MOSModule!(mos.objects.range);

@mosexport struct Range {
    Obj val;
    Obj end;
    Obj step;
    bool neg;
static:
    mixin MOSType!"range";
    @mosexport {
        void ctor(Pos p, Env e, Range* v, Obj[] args) {
            void init(Obj val, Obj end, Obj step) {
                v.val = val;
                v.end = end;
                v.step = step;
                v.neg = v.step.cmp(p, e, obj!Int(0)) < 0;
            }
            switch (args.length) {
            case 1:
                init(obj!Int(0), args[0], obj!Int(1));
                break;
            case 2:
                init(args[0], args[1], obj!Int(1));
                break;
            case 3:
                init(args[0], args[1], args[2]);
                break;
            default:
                invalidArgcRange(p, 1, 3, args.length);
                break;
            }
        }
        @mosget Range Iter(Range v) { return v; }
        @mosget Obj Val(Range v) { return v.val; }
        @mosget Obj Index(Range v) { return nil; }
        bool next(Pos p, Env e, Range* v) {
            v.val = v.val.binary!"+"(p, e, v.step);
            auto val = v.val.cmp(p, e, v.end);
            return v.neg ? val > 0 : val < 0;
        }
    }
}
