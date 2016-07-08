class EventListener {
    let store: Store
    let handler: () -> ()

    init(store: Store, handler: () -> ()) {
        self.store = store
        self.handler = handler
    }
}
