public protocol Action {

    #if swift(>=2.2)
        associatedtype Payload
        associatedtype Error: ErrorProtocol = NSError
    #else
        typealias Payload
        typealias Error: ErrorType = NSError
    #endif

    #if swift(>=3)
        func invoke(_ dispatcher: Dispatcher)
    #else
        func invoke(dispatcher: Dispatcher)
    #endif

}
