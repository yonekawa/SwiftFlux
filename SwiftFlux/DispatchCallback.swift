class DispatchCallback<T: Action> {
    let type: T.Type
    let handler: (Result<T.Payload, T.Error>) -> ()
    var status = DefaultDispatcher.Status.Waiting

    init(type: T.Type, handler: (Result<T.Payload, T.Error>) -> ()) {
        self.type = type
        self.handler = handler
    }
}
