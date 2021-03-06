module mos.stdlib.misc;

import mos.objects;

import stdd.format;

mixin MOSModule!(mos.stdlib.misc);
//import stdd.string;

private:

import stdd.random;

__gshared Mt19937_64 gen;

Obj toObj(T)(T t) {
    static if (is(T==Obj)) return t;
    else static if (is(T==mosint)) return obj!Int(t);
    else static if (is(T==bool)) return obj!Bool(t);
    else static if (is(T==mosfloat)) return obj!Float(t);
    else static if (is(T==mosstring)) return obj!String(t);
    else static if (is(T==Obj[Obj])) return obj!Map(t);
    else static if (is(T==real)) return obj!Float(t);
    else return new Obj(t);
}

public:

void init() {
    gen.seed(unpredictableSeed);
}
@mosexport {
    mosstring typestr(Obj a) {
        return a.typestr;
    }
    TypeMeta type(Obj a) {
        return a.typeMeta;
    }

    @mostrace Obj invalidType(Pos p, mosstring expected, mosstring got, string file = __FILE__, size_t line = __LINE__) {
        throw new RuntimeException(p, format!"Expected type %s, got %s"(expected, got), file, line);
    }

    @mostrace Obj invalidArgc(Pos p, mosint expected, mosint got, string file = __FILE__, size_t line = __LINE__) {
        throw new RuntimeException(p, format!"Expected %d args, got %s"(expected, got), file, line);
    }

    @mostrace Obj invalidArgcRange(Pos p, mosint min, mosint max, mosint got, string file = __FILE__, size_t line = __LINE__) {
        throw new RuntimeException(p, format!"Expected between %d and %s args, got %s"(min, max, got), file, line);
    }

    @mostrace void assert_(Pos p, Env e, Obj v, Obj[] args, string file = __FILE__, size_t line = __LINE__) {
        if (v.toBool(p, e))
            return;
        if (args.length == 0) {
            throw new RuntimeException(p, format!"assertion failed with value '%s'"(v.toString), file, line);
        }
        else if (args.length == 1) {
            throw new RuntimeException(p, format!"%s (%s)"(args[0].get!mosstring(p), v.toString), file, line);
        }
        invalidArgcRange(p, 1, 2, args.length);
    }
    void srand(mosint seed) {
        gen.seed(seed);
    }

    mosint randSeed() {
        return unpredictableSeed;
    }

    mosfloat rand() {
        return uniform01(gen); // rand();
    }

    Obj randrange(Pos p, Obj[] args) {
        //dfmt off
        if (args.length == 1) {
            return args[0].visitO!(
                (Int i) => toObj(uniform(0, i.val, gen)),
                (Float f) => toObj(uniform(0, f.val, gen)),
                () => invalidType(p, "int or float", args[0].typestr));
        }
        else if (args.length == 2) {
            return args[0].visitO!(
                    (Int a) => args[1].visitO!(
                        (Int b) => toObj(uniform(a.val, b.val, gen)),
                        (Float b) => toObj(uniform(a.val, b.val, gen)),
                        () => invalidType(p, "int or float", args[1].typestr)),
                    (Float a) => args[1].visitO!(
                        (Int b) => toObj(uniform(a.val, b.val, gen)),
                        (Float b) => toObj(uniform(a.val, b.val, gen)),
                        () => invalidType(p, "int or float", args[1].typestr)),
                    () => invalidType(p, "int or float", args[0].typestr));
        }
        else {
            return invalidArgcRange(p, 1, 2, args.length);
        }
        //dfmt on
    }
    mosint hash_(Obj o) {
        return o.toHash();
    }
}
