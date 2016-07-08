public class DefaultDispatcher: Dispatcher {

    internal enum Status {
        case Waiting
        case Pending
        case Handled
    }

    private var callbacks: [DispatchToken: AnyObject] = [:]

    public init() {}

    deinit {
        callbacks.removeAll()
    }

    #if swift(>=3)
        public func dispatch<T: Action>(_ action: T, result: Result<T.Payload, T.Error>) {
            dispatch(action.dynamicType, result: result)
        }
    #else
        public func dispatch<T: Action>(action: T, result: Result<T.Payload, T.Error>) {
            dispatch(action.dynamicType, result: result)
        }
    #endif

    #if swift(>=3)
        public func register<T: Action>(_ type: T.Type, handler: (Result<T.Payload, T.Error>) -> Void) -> DispatchToken {
            let nextDispatchToken = uuidString()
            callbacks[nextDispatchToken] = DispatchCallback<T>(type: type, handler: handler)
            return nextDispatchToken
        }
    #else
        public func register<T: Action>(type: T.Type, handler: (Result<T.Payload, T.Error>) -> Void) -> DispatchToken {
            let nextDispatchToken = uuidString()
            callbacks[nextDispatchToken] = DispatchCallback<T>(type: type, handler: handler)
            return nextDispatchToken
        }
    #endif

    #if swift(>=3)
        public func unregister(_ dispatchToken: DispatchToken) {
            callbacks.removeValue(forKey: dispatchToken)
        }
    #else
        public func unregister(dispatchToken: DispatchToken) {
            callbacks.removeValueForKey(dispatchToken)
        }
    #endif

    #if swift(>=3)
        public func waitFor<T: Action>(_ dispatchTokens: [DispatchToken], type: T.Type, result: Result<T.Payload, T.Error>) {
            for dispatchToken in dispatchTokens {
                guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { continue }
                switch callback.status {
                case .Handled:
                    continue
                case .Pending:
                    // Circular dependency detected while
                    continue
                default:
                    invokeCallback(dispatchToken, type: type, result: result)
                }
            }
        }
    #else
        public func waitFor<T: Action>(dispatchTokens: [DispatchToken], type: T.Type, result: Result<T.Payload, T.Error>) {
            for dispatchToken in dispatchTokens {
                guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { continue }
                switch callback.status {
                case .Handled:
                    continue
                case .Pending:
                    // Circular dependency detected while
                    continue
                default:
                    invokeCallback(dispatchToken, type: type, result: result)
                }
            }
        }
    #endif

    #if swift(>=3)
        private func dispatch<T: Action>(_ type: T.Type, result: Result<T.Payload, T.Error>) {
            objc_sync_enter(self)

            startDispatching(type)
            for dispatchToken in callbacks.keys {
                invokeCallback(dispatchToken, type: type, result: result)
            }

            objc_sync_exit(self)
        }
    #else
        private func dispatch<T: Action>(type: T.Type, result: Result<T.Payload, T.Error>) {
            objc_sync_enter(self)

            startDispatching(type)
            for dispatchToken in callbacks.keys {
                invokeCallback(dispatchToken, type: type, result: result)
            }

            objc_sync_exit(self)
        }
    #endif

    #if swift(>=3)
        private func startDispatching<T: Action>(_ type: T.Type) {
            for (dispatchToken, _) in callbacks {
                guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { continue }
                callback.status = .Waiting
            }
        }
    #else
        private func startDispatching<T: Action>(type: T.Type) {
            for (dispatchToken, _) in callbacks {
                guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { continue }
                callback.status = .Waiting
            }
        }
    #endif

    #if swift(>=3)
        private func invokeCallback<T: Action>(_ dispatchToken: DispatchToken, type: T.Type, result: Result<T.Payload, T.Error>) {
            guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { return }
            guard callback.status == .Waiting else { return }

            callback.status = .Pending
            callback.handler(result)
            callback.status = .Handled
        }
    #else
        private func invokeCallback<T: Action>(dispatchToken: DispatchToken, type: T.Type, result: Result<T.Payload, T.Error>) {
            guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { return }
            guard callback.status == .Waiting else { return }

            callback.status = .Pending
            callback.handler(result)
            callback.status = .Handled
        }
    #endif
}
