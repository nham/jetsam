import std.stdio, std.regex, std.variant, std.array;

void main() {
    writeln("hi");
    auto test_strs = ["hello", "409hello", "+", "-", "...", "@sym", "me@aol.com"];
    foreach(elem; test_strs) {
        writeln(elem, ": ", is_identifier(elem));
    }


    auto env = new Environment;
    Variant var = "abc";
    env.bindings["x"] = var;
    writeln(eval(new Node!string(null, "x"), env));
//    writeln(eval(new Node!string("y"), env));
    writeln(eval(new Node!string(null, "79"), env));
    writeln(eval(new Node!string(null, "#t"), env));
    writeln(eval(new Node!string(null, "\"dogs\""), env));
    writeln(eval(new Node!string(null, "quote", [new Node!string(null, "x")]), env));
    writeln(eval(new Node!string(null, "quote", [new Node!string(null, "y")]), env));

    writeln("==============parse============");
    auto doo = parse("( + 2 ( * 3 4 ) )");
    assert(doo !is null);
    doo.print();
    writeln();

    writeln("test an object tahts only been declared but not created with new");
}

class Node(T) {
    T val;
    Node!(T) parent;
    Node!(T)[] children;

    this(Node!(T) p) {
        this.parent = p;
    }

    this(Node!(T) p, T v) {
        this.parent = p;
        this.val = v;
    } 
    this(Node!(T) p, T v, Node!(T)[] ch) {
        this.parent = p;
        this.val = v;
        this.children = ch;
    }

    void print() {
        write("{", val, "}\n  [");
        foreach (i, ch; this.children) {
            ch.print();
            if (i != this.children.length - 1) write(", ");
        }
        write("]");
    }
}

unittest {
    Node!int x = new Node!int(33, [new Node!int(45), 
                                   new Node!int(7,
                                                [new Node!int(10)])
                                  ]);
    assert(x.val == 33);
    assert(x.children[1].val == 7);
}


class Environment {
    Variant[string] bindings;

    Variant lookup(string s) {
        auto p = s in bindings;
        if (p) {
            return *p;
        } else {
            throw new Exception("Identifier not found");
        }
    }
}

// naive approach of reading the entire program text into memory at once.
Node!string parse(string inp) {
    string[] sp = split(inp, " ");

    writeln(sp);
    Node!string curr;

    for(auto i = 0; i < sp.length; i++) {
        writeln("  i = ", i, ", sp[i] = ", sp[i]);
        // if we're on the root tree, we don't need to create again. it's
        // already created.
        if (sp[i] == "(") {
            if (curr is null) {
                curr = new Node!string(null);
            } else {
                curr.children ~= new Node!string(curr);
                curr = curr.children[$ - 1];
            }
        } else if(sp[i] == ")") {
            if (curr.parent !is null) {
                curr = curr.parent;
            }
        } else {
            if (curr.val == "") {
                curr.val = sp[i];
            } else {
                curr.children ~= new Node!string(curr, sp[i]);
            }
        }
    }

    writeln("about to return");

    return curr;
}

/*
unittest {
    assert(parse("( + 2 ( * 3 4 ) )")
    auto x = ["(", "+", "2", "(", "*", "3", "4", ")", ")"];
}
*/

Variant eval(Node!string x, Environment env) {
    Variant val;
    if (x.children == null) {
        if (is_identifier(x.val)) {
            val = env.lookup(x.val);
        } else {
            val = x.val;
        }
        return val;
    } else if (x.val == "quote") {
        if (x.children.length != 1) {
            throw new Exception("too many arguments.");
        } else {
            val = x.children[0].val;
            return val;
        }
    } else if (x.val == "if") {
        auto p = eval(x.children[0], env);
        if (p.type != typeid(bool)) {
            throw new Exception("First argument to 'if' is not a predicate.");
        } else {
            if (p == true) {
                return eval(x.children[1], env);
            } else {
                return eval(x.children[2], env);
            }
        }
    
    } else if (x.val == "lambda") {
        //val = function Variant(Variant z) { return eval(
        throw new Exception("ashkutrahsdt");
    } else {
        /*
        auto f = eval(x.val, env);
        auto chs = map!(y => eval(y, env))(x.children);
        */
        throw new Exception("ashkutrahsdt");
    }
}

bool is_identifier(string s) {
    string initial = r"a-z!$%&*/:<=>?^_~";
    string subsequent = initial ~ r"0-9+\-.@";
    string normal_id = r"[" 
                       ~ initial 
                       ~ r"][" 
                       ~ subsequent 
                       ~ r"]*";

    string peculiar_id = r"\+|-|\.\.\.";
    string id = r"^(" ~ normal_id ~ ")|(" ~ peculiar_id ~ ")$";

    if(match(s, id))
        return true;
    else
        return false;
}
