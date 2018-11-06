import Foundation
import LineNoise

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
  "rot": Rot(),
  ">": Gt(),
  "<": Lt(),
  ">=": Gte(),
  "<=": Lte(),
  "=": Eq(),
  "<-": Send()
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
