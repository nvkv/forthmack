import Foundation

private func binaryNumOperation(stack: inout Array<Val>, op: (Decimal, Decimal) -> Decimal) throws {
    if let first = stack.popLast(), let second = stack.popLast() {
        switch (first, second) {
        case (let .Number(a), let .Number(b)):
            stack.append(.Number(op(a, b)))
        default:
            throw InterpreterError.TypeError("Not numbers")
        }
    } else {
        throw InterpreterError.RuntimeError("Stack underflow")
    }
}


struct Plus: Word {
    let name = "+"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        try binaryNumOperation(stack: &stack, op: { a, b in a + b })
    }
}

struct Minus: Word {
    let name = "-"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        try binaryNumOperation(stack: &stack, op: { a, b in b - a })
    }
}

struct Divide: Word {
    let name = "/"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        try binaryNumOperation(stack: &stack, op: { a, b in b / a })
    }
}

struct Multiply: Word {
    let name = "*"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        try binaryNumOperation(stack: &stack, op: { a, b in a * b })
    }
}


struct Dot: Word {
    let name = "."
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        if let value = stack.popLast() {
            print(value)
        } else {
            throw InterpreterError.RuntimeError("Stack underflow")
        }
    }
}

struct Dup: Word {
    let name = "dup"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        if let value = stack.last {
            stack.append(value)
        } else {
            throw InterpreterError.RuntimeError("Stack underflow")
        }
    }
}

struct Drop: Word {
    let name = "drop"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        stack.removeLast()
    }
}

struct Swap: Word {
    let name = "swap"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        if let first = stack.popLast(), let second = stack.popLast() {
            stack.append(first)
            stack.append(second)
        }
    }
}

struct Over: Word {
    let name = "over"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        if stack.count >= 2 {
            let leaping = stack[stack.count - 2]
            stack.append(leaping)
        } else {
            throw InterpreterError.RuntimeError("Stack underflow")
        }
    }
}

struct Rot: Word {
    let name = "rot"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        if stack.count >= 3 {
            if let c = stack.popLast(), let b = stack.popLast(), let a = stack.popLast() {
                stack.append(b)
                stack.append(c)
                stack.append(a)
            } else {
                throw InterpreterError.RuntimeError("Can't get value from the stack")
            }
        } else {
            throw InterpreterError.RuntimeError("Stack underflow")
        }
    }
}


struct Load: Word {
    let name = "load"
    let isBuiltin = true
    let source: [Val] = []

    func run(stack: inout Array<Val>) throws {
        switch stack.popLast() {
        case let .some(.String(path)):
            let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            stack.append(contentsOf: try lexer(input: text))
        default:
            throw InterpreterError.RuntimeError("Can't open file")
        }
    }
}
