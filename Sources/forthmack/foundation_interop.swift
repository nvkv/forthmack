import Foundation

func sendMessage<T: NSObject>(obj: T, selector: String) throws -> Any? {
    return obj.perform(Selector(selector))?.takeRetainedValue() as! T
}
