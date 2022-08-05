module exception2;

/+
	It uses the long-form template writeup because I want to define the Parent separately
	and this just makes it a bit easier.
+/
template Exception2(alias Type, T...) {
	// Each piece of added data is a specialization of the more general
	// thing. This is realized by making the parent class just be the same
	// thing but with one piece chopped off.
	//
	// Or fallback to Exception as the generic parent of all Exception2s.
	static if(T.length)
		alias Parent = Exception2!(Type, T[0 .. $-1]);
	else
		alias Parent = Exception;

	class Exception2 : Parent {
		// this should probably be named differently or at least const or something
		// but it holds the data passed at the throw point
		T t;

		// This is the main entry point for throwing - notice how it takes the
		// arguments and forwards them to a new class - just like the factory pattern
		// often used in Phobos to construct, e.g., a MapResult from a map().
		//
		// If you tried to use `new Exception2` directly, you'd have to specify all those
		// types which you are about to pass, but with the opCall, the `R` is implicitly inferred.
		//
		// Note the inferred return value is the full static type passed down.
		static opCall(R...)(R r, string file = __FILE__, size_t line = __LINE__) {
			return new Exception2!(Type, T, R)(r, "", file, line); // that string could hold something i guess
		}

		// you wouldn't call this directly! I might even be able to make it `protected`
		this(T t, string msg, string file = __FILE__, size_t line = __LINE__) {
			this.t = t;
			static if(is(Parent == Exception))
				super(msg, file, line);
			else
				super(t[0 .. $-1], msg, file, line);
		}

		// this is basically the same as the old arsd.exception
		//nothing too special here
		override void toString(scope void delegate(in char[]) sink) const {

			import std.conv;

			sink(typeid(this).name); // FIXME: eponymous things so long of a name

			sink("@");

			sink(file);
			sink(":");
			sink(to!string(line));

			sink("\n");

			// because I love this phrasing lol
			// just a joke though
			sink("The program has performed an illegal operation and will be shut down.");

			// this part is real though: when printing, loop through the attached data
			// and show them all
			foreach(idx, item; t) {
				sink("\n");
				sink(typeof((cast() this).t[idx]).stringof);
				sink(" = ");
				sink(to!string(item));
			}

			if(info) {
				try {
					sink("\n----------------");
					foreach (t; info) {
						sink("\n"); sink(t);
					}
				}
				catch (Throwable) {
					// ignore more errors
				}
			}
		}
	}
}
