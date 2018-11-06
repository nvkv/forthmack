import Foundation

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
