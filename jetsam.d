import std.stdio;

void main() {
    writeln("hi");
    Node!int x = new Node!int(33, [new Node!int(45), 
                                   new Node!int(7,
                                                [new Node!int(10)])
                                  ]);
    writeln(x.val);
    x.print();
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

/*
// naive approach of reading the entire program text into memory at once.
string[] parse(string) {
    return ["+", [

}
*/
