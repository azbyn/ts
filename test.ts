#!/home/azbyn/Projects/qt_ts/qt_ts
capture = "k"
kp = "kp"
fun f[capture](var):
	module Foo[capture]:
		struct X:
			fun ctor(this): this.base = 4
			fun toString(this): this.base.toString()

		fun static(): 8
		fun static2(): Foo.X(Foo.static() +2)
		staticThing = Foo.static2()
		k = capture

	Console.setAttr(Attr.Bold, Color.Green)
	println(Console.Flags)
	Console.Fg = Color.Orange
	Console.Flags = Attr.Underline
	println(Foo.staticThing)
	println(var)
	Console.setAttr()
	Console.putnl()
#f(98)
fun d(x): x
println(d(5))
println(kp)
println(Math.Pi)
