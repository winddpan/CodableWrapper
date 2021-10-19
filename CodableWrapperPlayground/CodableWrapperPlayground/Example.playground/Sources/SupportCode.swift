
import Dispatch

public let debouncer = Debouncer(.seconds(0.1))
/// false: full-page log, yes:  invividual  example log
public var individualExampleEnabled = false

public func example(_ description: String, action: @escaping () throws -> Void) {
    if individualExampleEnabled {
        debouncer.callback = {
            print("\n\n---- \(description) ----")
            do {
                try action()
            } catch {
                print(error)
            }
        }
        debouncer.call()
    } else {
        print("\n\n---- \(description) ----")
        do {
            try action()
        } catch {
            print(error)
        }
    }
}

public func delay(_ delay: Double, closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}
