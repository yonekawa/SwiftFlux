public protocol Action {

    #if swift(>=2.2)
        associatedtype Payload
        associatedtype Error: ErrorType = NSError
    #else
        typealias Payload
        typealias Error: ErrorType = NSError
    #endif

    func invoke(dispatcher: Dispatcher)
}

public class ActionCreator {

    private static let internalDefaultDispatcher = DefaultDispatcher()

    public class var dispatcher: Dispatcher {
        return internalDefaultDispatcher;
    }

    public class func invoke<T: Action>(action: T) {
        action.invoke(self.dispatcher)
    }
}
