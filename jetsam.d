import std.stdio, std.regex, std.variant;

void main() {
    writeln("hi");
    auto test_strs = ["hello", "409hello", "+", "-", "...", "@sym", "me@aol.com"];
    foreach(elem; test_strs) {
        writeln(elem, ": ", is_identifier(elem));
    }
}

class Node(T) {
    T val;
    Node[] children;
    this(T v) {
        this.val = v;
    }

    this(T v, Node[] ch) {
        this.val = v;
        this.children = ch;
    }

    void print() {
        write(val, " [");
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
    string[string] bindings;

    string lookup(string s) {
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
    return new Node!string("+", [new Node!string("1"), new Node!string("2")]);
}

Variant eval(Node!string x, Environment env) {
    Variant val;
    if (x.children == null) {
        if (is_symbol(x.val)) {
            val = env.syms[x.val];
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
        // bluh
    } else {
        auto f = eval(x.val, env);
        auto chs = map!(y => eval(y, env))(x.children);
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

bool is_symbol(string s) {
    return false;
}
