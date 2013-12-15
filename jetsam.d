import std.stdio, std.regex, std.contracts;

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

struct Value {
    enum Type { _tbool, _tsym, _tchar, _tvec, _tproc, _tpair, _tnum, _tstr, _tport }
    private Type _type;

    private union {
        bool _tbool;
        string _tsym;
        char _tchar;
        string _tstr;
        double _tnum;
    }

    public:
        void opAssign(bool v) {
            _tbool = v;
            _tag = Type._tbool;
        }

        bool get() {

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
    string[string] syms;
}

// naive approach of reading the entire program text into memory at once.
Node!string parse(string inp) {
    return new Node!string("+", [new Node!string("1"), new Node!string("2")]);
}

string eval(Node!string x, Environment env) {
    if (x.children == null) {
        if (is_symbol(x.val)) {
            return env.syms[x.val];
        } else {
            return x.val;
        }
    } else if (x.val == "quote") {
        if (x.children.length != 1) {
            return "ERROR. ALSO THIS NEEDS TO REALLY BE AN ERROR";
        } else {
            return x.children[0].val;
        }
    
    } else {
        return "ERROR. ALSO THIS NEEDS TO REALLY BE AN ERROR";
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
