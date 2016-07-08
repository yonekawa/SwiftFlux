public class StoreBase: Store {
    private var dispatchTokens: [DispatchToken] = []

    public init() {}

    public func register<T: Action>(type: T.Type, handler: (Result<T.Payload, T.Error>) -> ()) -> DispatchToken {
        let dispatchToken = ActionCreator.dispatcher.register(type) { (result) -> () in
            handler(result)
        }
        dispatchTokens.append(dispatchToken)
        return dispatchToken
    }

    public func unregister() {
        dispatchTokens.forEach { (dispatchToken) -> () in
            ActionCreator.dispatcher.unregister(dispatchToken)
        }
    }
}
