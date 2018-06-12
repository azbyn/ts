module ts.ir.compiler;

import stdd.array;
import stdd.variant;
import stdd.algorithm;
import stdd.format;
import ts.objects.obj;
import ts.ast.ast_node;
import ts.ast.token;
import ts.ir.block_manager;
import ts.ir.block;
import ts.ir.symbol_table;
import ts.ir.lib;
import ts.misc;
import com.log;


//TODO make case insensitive?

enum OPCode {
    Nop,
    Pop,
    DupTop,
    Call,
    MemberSet,
    MemberGet,
    SubscriptGet,
    SubscriptSet,
    Return,
    LoadConst,
    LoadVal,
    LoadLib,
    Assign,
    SetterDef,
    GetterDef,
    PropDef,
    MakeList,
    MakeTuple,
    MakeDict,
    MakeClosure,
    MakeModule,
    Jmp,
    Cmp,
    Cat,
    Binary,
    JmpIfTrueOrPop, // if (prev) { jmp } else { pop }
    JmpIfFalseOrPop, // if (!prev) { jmp } else { pop }
    JmpIfTruePop, // if (prev) { jmp }  pop
    JmpIfFalsePop, // if (!prev) { jmp } pop
}

struct OP {
    Pos pos;
    OPCode code;
    //ushort argc;
    uint val;
    tsstring toString() {
        return tsformat!"%-20s v:%d"(code, val);
        //return tsformat!"%-20s a:%d v:%d"(code, argc, val);
    }
}

Block generateIR(AstNode n, Block parent, tsstring[] captures, tsstring[] args, bool isVariadic) {
    return generateIR(n, parent, parent.man.getBulk(captures), parent.man.addBulk(args), isVariadic);
}

Block generateIR(AstNode n, Block parent, uint[] captures, uint[] args, bool isVariadic) {
    assert(parent);
    assert(parent.man);
    //assert(parent.man);
    Block bl = new Block(parent.man, args, captures, isVariadic);
    if (auto body_ = n.val.peek!(AstNode.Body)){
        foreach (node; body_.val) {
            nodeIR(node, bl);
            bl.add(n.pos, OPCode.Pop);
        }
        if (bl.ops.length > 1)
            bl.ops.popBack();
    }
    else nodeIR(n, bl);
    return bl;
}

BlockManager generateIR(AstNode[] nodes, Lib lib) {
    Block bl;
    BlockManager man = new BlockManager(lib, bl);
    foreach (n; nodes) {
        nodeIR(n, bl);
        bl.add(n.pos, OPCode.Pop);
    }
    return man;
}
private void nodeIR(AstNode n, Block bl, ulong loopBeg = -1, ulong loopEnd = -1) {
    assert(bl);
    void ir(AstNode node, ulong beg = loopBeg, ulong end = loopEnd) {
        return node.nodeIR(bl, beg, end);
    }
    auto pos = n.pos;
    //dfmt off
    n.val.visit!(
        (AstNode.Comma v) {
            ir(v.a);
            bl.add(pos, OPCode.Pop);
            ir(v.b);
        },
        (AstNode.ReverseComma v) {
            ir(v.a);
            ir(v.b);
            bl.add(pos, OPCode.Pop);
        },
        (AstNode.String v) {
            bl.addConst(pos, objString(v.val));
        },
        (AstNode.Float v) {
            bl.addConst(pos, objFloat(v));
        },
        (AstNode.Int v) {
            bl.addConst(pos, objInt(v));
        },
        (AstNode.Bool v) {
            bl.addConst(pos, objBool(v));
        },
        (AstNode.Nil v) {
            bl.addNil(pos);
        },
        (AstNode.Variable v) {
            bl.addVariable(pos, v.name);
        },
        (AstNode.FuncCall v) {
            ir(v.func);
            foreach (n; v.args) {
                ir(n);
            }
            bl.addVal(pos, OPCode.Call, v.args.length);
        },
        (AstNode.Binary v) {
            ir(v.a);
            ir(v.b);
            bl.addStr(pos, OPCode.Binary, v.name);
        },
        (AstNode.Lambda v) {
            auto block = generateIR(v.body_, bl, v.captures, v.params, v.isVariadic);
            bl.addClosureOrFunc(pos, block);
        },
        (AstNode.Assign v) {
            v.rvalue.val.tryVisit!(
                (AstNode.Variable r) {
                    ir(v.lvalue);
                    bl.addAssign(pos, r.name);
                },
                (AstNode.Member r) {
                    ir(r.val);
                    ir(v.lvalue);
                    bl.addStr(pos, OPCode.MemberSet, r.member);
                },
                (AstNode.Subscript r) {
                    ir(r.val);
                    ir(r.index);
                    ir(v.lvalue);
                    bl.add(pos, OPCode.SubscriptSet);
                },
                () { throw new IRException(pos, "Invalid assignment"); }
            )();
        },
        (AstNode.SetterDef v) {
            ir(v.val);
            bl.addSetterDef(pos, v.name);
        },
        (AstNode.GetterDef v) {
            ir(v.val);
            bl.addGetterDef(pos, v.name);
        },
        (AstNode.PropDef v) {
            uint[] caps = bl.man.tryGetBulk(v.get.captures);
            bl.addClosureOrFunc(pos, generateIR(v.get.body_, bl, caps, [], false));
            bl.addClosureOrFunc(pos, generateIR(v.set.body_, bl, caps, bl.man.addBulk(v.set.params), false));
            bl.addPropDef(pos, v.name);
        },
        (AstNode.Subscript v) {
            ir(v.val);
            ir(v.index);
            bl.add(pos, OPCode.SubscriptGet);
        },
        (AstNode.Member v) {
            ir(v.val);
            bl.addStr(pos, OPCode.MemberGet, v.member);
        },
        (AstNode.And v) {
            ir(v.a);
            auto j = bl.addJmp(pos, OPCode.JmpIfFalseOrPop);
            ir(v.b);
            bl.setJmpHere(j);
        },
        (AstNode.Or v) {
            ir(v.a);
            auto j = bl.addJmp(pos, OPCode.JmpIfTrueOrPop);
            ir(v.b);
            bl.setJmpHere(j);
        },
        (AstNode.If v) {
            ir(v.cond);
            auto j1 = bl.addJmp(pos, OPCode.JmpIfFalseOrPop);
            ir(v.body_);
            auto j2 = bl.addJmp(pos, OPCode.Jmp);
            bl.setJmpHere(j1);
            if (v.else_ !is null)
                ir(v.else_);
            bl.setJmpHere(j2);
        },
        (AstNode.While v) {
            auto beg = bl.here();
            auto end = bl.reserveJmp();
            ir(v.cond);
            bl.addVal(pos, OPCode.JmpIfFalseOrPop, end);
            ir(v.body_, beg, end);
            bl.addVal(pos, OPCode.Jmp, beg);
            bl.setJmpHere(end);
        },
        (AstNode.For v) {
            /*
              iter = collection.Iter;
            beg:
              v.index = iter.Index;
              v.val = iter.Val;
              body();
            next:
              if (iter.next()) goto beg;
            end:
             */
            ir(v.collection);
            bl.addStr(pos, OPCode.MemberGet, "Iter");
            auto iter = bl.addAssignTemp(pos);
            bl.add(pos, OPCode.Pop);
            auto beg = bl.here();
            auto next = bl.reserveJmp();
            auto end = bl.reserveJmp();

            bl.addVal(pos, OPCode.LoadVal, iter);
            bl.addStr(pos, OPCode.MemberGet, "Index");
            bl.addAssign(pos, v.index);
            bl.add(pos, OPCode.Pop);

            bl.addVal(pos, OPCode.LoadVal, iter);
            bl.addStr(pos, OPCode.MemberGet, "Val");
            bl.addAssign(pos, v.val);
            bl.add(pos, OPCode.Pop);
            ir(v.body_, beg, end);

            bl.setJmpHere(next);
            bl.addVal(pos, OPCode.LoadVal, iter);
            bl.addStr(pos, OPCode.MemberGet, "next");
            bl.addVal(pos, OPCode.Call, 0);
            bl.addVal(pos, OPCode.JmpIfTruePop, beg);
            bl.setJmpHere(end);
        },
        (AstNode.Body v) {
            //bodies don't create a new scope
            foreach(n; v.val) {
                ir(n);
                bl.add(pos, OPCode.Pop);
            }
        },
        (AstNode.List v) {
            foreach(n; v.val) {
                ir(n);
            }
            bl.addVal(pos, OPCode.MakeList, v.val.length);
        },
        (AstNode.Tuple v) {
            foreach(n; v.val) {
                ir(n);
            }
            bl.addVal(pos, OPCode.MakeTuple, v.val.length);
        },
        (AstNode.Dict v) {
            foreach(n; v.val) {
                ir(n);
            }
            bl.addVal(pos, OPCode.MakeDict, v.val.length);
        },

        (AstNode.Cmp v) {
            ir(v.a);
            ir(v.b);
            bl.addVal(pos, OPCode.Cmp, cast(int)v.op);
        },
        (AstNode.Cat v) {
            ir(v.a);
            ir(v.b);
            bl.add(pos, OPCode.Cat);
        },

        (AstNode.Return v) {
            ir(v.val);
            bl.add(pos, OPCode.Return);
        },
        (AstNode.CtrlFlow v) {
            //import ts.ast.parser;
            if (loopBeg == -1)
                throw new IRException(pos, format!"Found %s outside loop"(v.type.symbolicStr));
            assert (loopEnd != -1);
            auto j = v.type == TT.Break ? loopEnd : loopBeg;
            tslog!"jmp from %d-%d: %d"(loopBeg, loopEnd, j);
            bl.addVal(pos, OPCode.Jmp, j);
        },
        (AstNode.Module v) {
            ModuleMaker tm = ModuleMaker(v.isType, v.name);
            uint struct_ = bl.st.addStr(v.name);

            Block getBlock(AstNode.Lambda l) {
                return generateIR(l.body_, bl, bl.man.getBulk(l.captures) ~ struct_, bl.man.addBulk(l.params), l.isVariadic);
            }
            tm.captures = bl.man.getBulk(v.captures) ~ struct_;
            foreach (name, m; v.members) {
                tm.members[name] = generateIR(m, bl, tm.captures, [], false);
            }
            foreach (name, m; v.methods) {
                tm.methods[name] = getBlock(m);
            }
            foreach (name, m; v.getters) {
                tm.getters[name] = getBlock(m);
            }
            foreach (name, m; v.setters) {
                tm.setters[name] = getBlock(m);
            }
            bl.addModule(pos, tm);
        },
    )();
    //dfmt on
}
