import Foundation
import LineNoise

enum Val: Equatable {
    case Word(String)
    case Number(Decimal)
    case String(String)
    case Comment

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

func nextToken(input: String) -> (Val, String) {
    let whitespace = CharacterSet.whitespacesAndNewlines
    let line = input.trimmingCharacters(in: whitespace)

    if let quote = line.first, quote == "\"" {
        let token = line.dropFirst().prefix(while: { c in c != "\"" })
        return (.String(String(token)), String(line.dropFirst(token.count + 2)))
    }

    if let comment = line.first, comment == "(" {
        let rest = line.drop(while: { c in c != ")" })
        return (.Comment, String(rest.dropFirst()))
    }

    if let lineComment = line.first, lineComment == "\\" {
        let rest = line.drop(while: { c in c != "\n" })
        return (.Comment, String(rest.dropFirst()))
    }

    if input.rangeOfCharacter(from: whitespace) == nil {
        return (.Word(line), "")
    }

    let token = line.prefix(while: { c in !CharacterSet(charactersIn: String(c)).isSubset(of: whitespace) })
    let numberCharacters = NSCharacterSet(charactersIn: "0123456789.").inverted
    if  token != ".", token.rangeOfCharacter(from: numberCharacters) == nil, let number = Decimal(string: String(token)) {
        return (.Number(number), String(line.dropFirst(token.count + 1)))
    }
    return (.Word(String(token)), String(line.dropFirst(token.count + 1)))
}

func lexer(input: String) throws -> Array<Val> {
    var remainder = input
    var tokens: Array<Val> = []
    while !remainder.isEmpty  {
        let (token, rem) = nextToken(input: remainder)
        switch token {
        case .Comment: break
        default:
            tokens.append(token)
        }
        remainder = rem
    }
    return tokens
}

// print(try! lexer(input: "42 42 +"))
// print(try! lexer(input: "25.2 19.7 /"))
// print(try! lexer(input: ": default-one \"hello world\" ;"))
// print(try! lexer(input: ": no-more \"Hit the road Jack\" 2 times . ;"))
// print(try! lexer(input: "\"Hello Fucking Forth Interpreter!\""))
// print(try! lexer(input: ": no-more\t(n -- n)\n\t\"Мама, чому я такой тупой?\" 2 times . ;"))

// let multiline = """
// \\ Views:
// : page-title \"hmmmm\" ;
// : handle-/index
//     \"index.html\" render-view ;
// : handle-import
//     \"import-version.html\" render-view ;

// /1991 /index handle-/index
// /1991 /import handle-import
// """

// print(try! lexer(input: multiline))

let plus = Plus()
let minus = Minus()
let divide = Divide()
let multiply = Multiply()
let dot = Dot()
let dup = Dup()
let load = Load()

var dict: [String: Word] = [
  plus.name: plus,
  minus.name: minus,
  divide.name: divide,
  multiply.name: multiply,
  dot.name: dot,
  dup.name: dup,
  load.name: load,
  "swap": Swap(),
  "drop": Drop(),
  "over": Over(),
  "rot": Rot()
]

let ln = LineNoise()
while true {
    do {
	      let input = try ln.getLine(prompt: "> ")
	      ln.addHistory(input)
        print()
        let source = try! lexer(input: input)
        print(try run(source: source, dict: &dict))
        print("ok")
    } catch {
        switch error {
        case LinenoiseError.EOF:
            fallthrough
        case LinenoiseError.CTRL_C:
            exit(1)
        default:
            print(error)
        }
    }
}
