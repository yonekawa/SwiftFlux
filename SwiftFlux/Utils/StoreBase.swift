public class StoreBase: Store {
    private var dispatchTokens: [DispatchToken] = []

    public init() {}

    #if swift(>=3)
        public func register<T: Action>(_ type: T.Type, handler: (Result<T.Payload, T.Error>) -> ()) -> DispatchToken {
            let dispatchToken = ActionCreator.dispatcher.register(type) { (result) -> () in
                handler(result)
            }
            dispatchTokens.append(dispatchToken)
            return dispatchToken
        }
    #else
        public func register<T: Action>(type: T.Type, handler: (Result<T.Payload, T.Error>) -> ()) -> DispatchToken {
            let dispatchToken = ActionCreator.dispatcher.register(type) { (result) -> () in
                handler(result)
            }
            dispatchTokens.append(dispatchToken)
            return dispatchToken
        }
    #endif

    public func unregister() {
        dispatchTokens.forEach { (dispatchToken) -> () in
            ActionCreator.dispatcher.unregister(dispatchToken)
        }
    }
}
