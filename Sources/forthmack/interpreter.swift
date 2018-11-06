import Foundation

enum Val: Equatable {
    case Word(String)
    case Number(Decimal)
    case String(String)
    case Comment
    case Definition([Val])
    case Condition([Val], [Val])
    case Loop(Int, Int, [Val])

    static func ==(left: Val, right: Val) -> Bool {
        switch (left, right) {
        case (let .Word(w1), let .Word(w2)):
            return w1 == w2
        case (let .String(s1), let .String(s2)):
            return s1 == s2
        case (let .Number(n1), let .Number(n2)):
            return n1 == n2
        default:
            return false
        }
    }
}

enum InterpreterError: Error {
    case TypeError(String)
    case SyntaxError(String)
    case RuntimeError(String)
}

protocol Word {
    var name: String { get }
    var isBuiltin: Bool { get }
    func run(stack: inout Array<Val>) throws
    var source: [Val] { get }
}

struct DefinedWord: Word {
    var name: String
    var isBuiltin: Bool = false
    let source: [Val]

    func run(stack: inout Array<Val>) throws {}
}

func group(source: [Val]) throws -> [Val] {
    var groupedSource: [Val] = []
    var i = 0;
    while i < source.count {
        let token = source[i]
        switch token {
        case .Word(":"):
            if let end = source[i ..< source.count].firstIndex(of: .Word(";")) {
                let def = source[i + 1 ..< end]
                groupedSource.append(.Definition(Array(def)))
                i += end + 1
            }
        case .Word("if"):
            if let end = source[i ..< source.count].firstIndex(of: .Word("then")) {
                var trueBranch: [Val] = []
                var elseBranch: [Val] = []
                if let elseb = source[i ..< source.count].firstIndex(of: .Word("else")) {
                    trueBranch = Array(source[i + 1 ..< elseb])
                    elseBranch = Array(source[elseb + 1 ..< end])
                } else {
                    trueBranch = Array(source[i + 1 ..< end])
                }
                groupedSource.append(.Condition(trueBranch, elseBranch))
                i += end
            } else {
                throw InterpreterError.SyntaxError("Condition must be ending with 'then'")
            }

        case .Word("do"):
            if let from = groupedSource.popLast(), let to = groupedSource.popLast() {
                if let end = source[i ..< source.count].firstIndex(of: .Word("loop")) {
                    let body = Array(source[i + 1 ..< end])
                    switch (from, to) {
                    case (let .Number(f), let .Number(t)):
                        groupedSource.append(
                          .Loop(
                            NSDecimalNumber(decimal: f).intValue,
                            NSDecimalNumber(decimal: t).intValue,
                            body
                          )
                        )
                    default:
                        throw InterpreterError.SyntaxError("Loop indices must be numbers")
                    }
                    i += end
                } else {
                    throw InterpreterError.SyntaxError("Do must be ending with 'loop'")
                }
            } else {
                throw InterpreterError.SyntaxError("Missing indices for do loop")
            }

        default:
            groupedSource.append(token)
            i += 1
        }
    }
    return groupedSource
}

func run(source: Array<Val>, dict: inout Dictionary<String, Word>) throws -> Array<Val> {
    var stack = Array<Val>()
    let src = try group(source: source)

    for token in src {
        switch token {
        case .Word("words"):
            print("Name \t Builtin?")
            for (name, def) in dict {
                print("\(name) \t \(def.isBuiltin)")
            }
        case let .Definition(def):
            if let wordName = def.first {
                switch wordName {
                case let .Word(name):
                    let word = DefinedWord(name: name, isBuiltin: false, source: Array(def.dropFirst()))
                    dict[word.name] = word
                default:
                    throw InterpreterError.SyntaxError("Definition is missing a word")
                }
            } else {
                throw InterpreterError.SyntaxError("Definition is missing a word")
            }
        case let .Condition(t, f):
            if let checkFor = stack.popLast() {
                switch checkFor {
                case let .Number(n):
                    if n.isZero {
                        stack.append(contentsOf: f)
                    } else {
                        stack.append(contentsOf: t)
                    }
                default:
                    throw InterpreterError.SyntaxError("Condition should be Number")
                }
            } else {
                throw InterpreterError.SyntaxError("Missing condition")
            }

        case let .Loop(from, to, body):
            for i in from ..< to {
                let executeBody = body.map { (val: Val) -> Val in
                    if val == .Word("i") {
                        return .Number(Decimal(i))
                    }
                    return val
                }
                stack.append(contentsOf: try run(source: executeBody, dict: &dict))
            }
        case let .Word(w):
            if let word = dict[w] {
                if word.isBuiltin {
                    let _ = try word.run(stack: &stack)
                } else {
                    stack.append(contentsOf: word.source)
                }
                stack = try run(source: stack, dict: &dict)
            } else {
                stack.append(token)
            }
        default:
            stack.append(token)
        }
    }
    return stack
}
