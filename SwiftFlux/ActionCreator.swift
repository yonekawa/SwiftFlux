public class ActionCreator {

    private static let internalDefaultDispatcher = DefaultDispatcher()

    public class var dispatcher: Dispatcher {
        return internalDefaultDispatcher;
    }

    #if swift(>=3)
        public class func invoke<T: Action>(_ action: T) {
            action.invoke(self.dispatcher)
        }
    #else
        public class func invoke<T: Action>(action: T) {
            action.invoke(self.dispatcher)
        }
    #endif
}
