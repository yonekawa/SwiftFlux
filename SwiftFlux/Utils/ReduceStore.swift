public class ReduceStore<T: Equatable>: StoreBase {
    public init(initialState: T) {
        self.initialState = initialState
        super.init()
    }

    private var initialState: T
    private var internalState: T?
    public var state: T {
        return internalState ?? initialState
    }

    public func reduce<A: Action>(type: A.Type, reducer: (T, Result<A.Payload, A.Error>) -> T) -> DispatchToken {
        return self.register(type) { (result) in
            let startState = self.state
            self.internalState = reducer(self.state, result)
            if startState != self.state {
               self.emitChange()
            }
        }
    }
}
