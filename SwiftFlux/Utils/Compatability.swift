import Foundation

#if swift(>=3)
#else
    public typealias ErrorProtocol = ErrorType
#endif

func uuidString() -> String {
    #if swift(>=3)
        return UUID().uuidString
    #else
        return NSUUID().UUIDString
    #endif
}
