import QtQuick 2.0
import QtQuick.Controls.Styles 1.0
import ts 1.0

Keypad {
    function back(){
        ep.setCurr(KeypadType.Main);
    }

    quickData: [
        ["back", function(){ back(); } ],
        ["<-",   function(){ editor.cursorLeft(); } ],
        ["->",   function(){ editor.cursorRight() ;} ],
        ["undo", function(){}],
        ["redo", function(){}],
        ["⌫",  function(){ editor.del(); } ],
    ]
    quickPerc: 0.1

    sizeX: 3
    sizeY: 2
    perc: 0.108 * sizeY
    btnData: [
        ["λ", function(){
            editor.addLambda();
            editor.addArrow();
            editor.cursorLeft();
            back();
        }],
        ["[]", function(){ editor.addSquarePair(); back(); }],
        ["{}", function(){ editor.addCurlyPair(); back(); }],

        ["true",  function(){ editor.addTrue(); back(); }],
        ["false", function(){ editor.addFalse(); back(); }],
        ["nil",   function(){ editor.addNil(); back(); }],
    ]
}