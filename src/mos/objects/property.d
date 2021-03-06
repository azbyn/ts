module mos.objects.property;

import mos.objects.obj;
import stdd.format;

mixin MOSModule!(mos.objects.property);

import com.log;
private alias Method = Obj delegate(Obj) @system;
@mosexport struct PropertyMember {
    mixin MOSType!"property_member";
    Method get = null;
    Method set = null;

    this(Method get, Method set) {
        this.get = get;
        this.set = set;
    }
    Obj callGet(Pos p, Env e, Obj this_) {
        if (!get)
            throw new RuntimeException(p, "property doesn't have a getter");
        return get(this_).call(p, e);
    }
    Obj callSet(Pos p, Env e, Obj this_, Obj val) {
        if (!set)
            throw new RuntimeException(p, "property doesn't have a setter");

        return set(this_).call(p, e, val);
    }
static:
    /*
    Obj opFwd(Pos p, Env e, Property prop, mosstring name) {
        return prop.callGet(p,e).getMember(p,e, name);
    }
    Obj opFwdSet(Pos p, Env e, Property prop, mosstring name, Obj val) {
        auto obj = prop.callGet(p, e);
        obj.setMember(p, e, name, val);
        return prop.callSet(p, e, obj);
        }*/
}
@mosexport struct Property {
    mixin MOSType!"property";
    Obj get = null;
    Obj set = null;
    this(Obj get, Obj set) {
        this.get = get;
        this.set = set;
    }
    Obj callGet(Pos p, Env e) {
        if (!get)
            throw new RuntimeException(p, "property doesn't have a getter");
        return get.call(p, e);
    }
    Obj callSet(Pos p, Env e, Obj val) {
        if (!set)
            throw new RuntimeException(p, "property doesn't have a setter");

        return set.call(p, e, val);
    }
static:
    /*
    Obj opFwd(Pos p, Env e, Property prop, mosstring name) {
        return prop.callGet(p,e).getMember(p,e, name);
    }
    Obj opFwdSet(Pos p, Env e, Property prop, mosstring name, Obj val) {
        auto obj = prop.callGet(p, e);
        obj.setMember(p, e, name, val);
        return prop.callSet(p, e, obj);
        }*/
}

Obj assignSetter(Index)(ref Obj[Index] arr, Index index, Obj val) {
    Property* p;
    Obj* ptr = index in arr;
    if (ptr !is null && (p = ptr.peek!Property) !is null) {
        return p.set = val;
    }
    return arr[index] = obj!Property(null, val);
}
Obj assignGetter(Index)(ref Obj[Index] arr, Index index, Obj val) {
    Property* p;
    Obj* ptr = index in arr;
    if (ptr !is null && (p = ptr.peek!Property) !is null) {
        return p.get = val;
    }
    return arr[index] = obj!Property(val, null);
}
Obj assignFuncType(FuncType ft, Index)(ref Obj[Index] arr, Index index, Obj val) {
    static if (ft == FuncType.Getter) {
        return assignGetter(arr, index, val);
    }
    else static if (ft == FuncType.Setter) {
        return assignSetter(arr, index, val);
    }
    else {
        return arr[index] = val;
    }
}


Obj assignMemberSetter(Index)(ref Obj[Index] arr, Index index, Method val) {
    PropertyMember* p;
    Obj* ptr = index in arr;
    if (ptr !is null && (p = ptr.peek!PropertyMember) !is null) {
        p.set = val;
        return nil;
    }
    return arr[index] = obj!PropertyMember(null, val);
}
Obj assignMemberGetter(Index)(ref Obj[Index] arr, Index index, Method val) {
    PropertyMember* p;
    Obj* ptr = index in arr;
    if (ptr !is null && (p = ptr.peek!PropertyMember) !is null) {
        p.get = val;
        return nil;
    }
    return arr[index] = obj!PropertyMember(val, null);
}
Obj assignMemberFuncType(FuncType ft, Index)(ref Obj[Index] arr, Index index, Method val) {
    static if (ft == FuncType.Getter) {
        return assignMemberGetter(arr, index, val);
    }
    else static if (ft == FuncType.Setter) {
        return assignMemberSetter(arr, index, val);
    }
    else {
        return arr[index] = obj!BIMethodMaker(val);
    }
}

