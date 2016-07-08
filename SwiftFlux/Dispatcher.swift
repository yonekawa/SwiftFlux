public typealias DispatchToken = String

public protocol Dispatcher {

    #if swift(>=3)
        func dispatch<T: Action>(_ action: T, result: Result<T.Payload, T.Error>)
        func register<T: Action>(_ type: T.Type, handler: (Result<T.Payload, T.Error>) -> ()) -> DispatchToken
        func unregister(_ dispatchToken: DispatchToken)
        func waitFor<T: Action>(_ dispatchTokens: [DispatchToken], type: T.Type, result: Result<T.Payload, T.Error>)
    #else
        func dispatch<T: Action>(action: T, result: Result<T.Payload, T.Error>)
        func register<T: Action>(type: T.Type, handler: (Result<T.Payload, T.Error>) -> ()) -> DispatchToken
        func unregister(dispatchToken: DispatchToken)
        func waitFor<T: Action>(dispatchTokens: [DispatchToken], type: T.Type, result: Result<T.Payload, T.Error>)
    #endif
}
