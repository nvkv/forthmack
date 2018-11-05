import Foundation

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

func run(source: Array<Val>, dict: inout Dictionary<String, Word>) throws -> Array<Val> {
    var stack = Array<Val>()
    var curDefinition: [Val]? = nil

    for token in source {
        switch token {
        case .Word("words"):
            print(dict)
        case .Word(":"):
            curDefinition = []
        case .Word(";"):
            if let word = curDefinition?.first {
                switch word {
                case let .Word(w):
                    curDefinition?.removeFirst()
                    let wordImpl = DefinedWord(name: w, isBuiltin: false, source: curDefinition!)
                    dict[wordImpl.name] = wordImpl
                default:
                    throw InterpreterError.SyntaxError("Definition is missing a word")
                }
            }
            curDefinition = nil
        case let .Word(w):
            if curDefinition != nil {
                fallthrough
            }
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
            if curDefinition != nil {
                curDefinition?.append(token)
            } else {
                stack.append(token)
            }
        }
    }
    return stack
}
