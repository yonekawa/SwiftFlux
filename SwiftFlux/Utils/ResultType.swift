//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// A type that can represent either failure with an error or success with a result value.
public protocol ResultType {

    #if swift(>=2.1)
        associatedtype Value
        associatedtype Error: ErrorProtocol
    #else
        typealias Value
        typealias Error: ErrorProtocol
    #endif
	
	/// Constructs a successful result wrapping a `value`.
	init(value: Value)

	/// Constructs a failed result wrapping an `error`.
	init(error: Error)
	
	/// Case analysis for ResultType.
	///
	/// Returns the value produced by appliying `ifFailure` to the error if self represents a failure, or `ifSuccess` to the result value if self represents a success.
    #if swift(>=3)
        func analysis<U>(ifSuccess: @noescape (Value) -> U, ifFailure: @noescape (Error) -> U) -> U
    #else
        func analysis<U>(@noescape ifSuccess ifSuccess: Value -> U, @noescape ifFailure: Error -> U) -> U
    #endif

	/// Returns the value if self represents a success, `nil` otherwise.
	///
	/// A default implementation is provided by a protocol extension. Conforming types may specialize it.
	var value: Value? { get }

	/// Returns the error if self represents a failure, `nil` otherwise.
	///
	/// A default implementation is provided by a protocol extension. Conforming types may specialize it.
	var error: Error? { get }
}

public extension ResultType {
	
	/// Returns the value if self represents a success, `nil` otherwise.
	public var value: Value? {
		return analysis(ifSuccess: { $0 }, ifFailure: { _ in nil })
	}
	
	/// Returns the error if self represents a failure, `nil` otherwise.
	public var error: Error? {
		return analysis(ifSuccess: { _ in nil }, ifFailure: { $0 })
	}

	/// Returns a new Result by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
    #if swift(>=3)
        public func map<U>(_ transform: @noescape (Value) -> U) -> Result<U, Error> {
            return flatMap { .Success(transform($0)) }
        }
    #else
        public func map<U>(@noescape transform: Value -> U) -> Result<U, Error> {
            return flatMap { .Success(transform($0)) }
        }
    #endif

	/// Returns the result of applying `transform` to `Success`es’ values, or re-wrapping `Failure`’s errors.
    #if swift(>=3)
        public func flatMap<U>(_ transform: @noescape (Value) -> Result<U, Error>) -> Result<U, Error> {
            return analysis(
                ifSuccess: transform,
                ifFailure: Result<U, Error>.Failure)
        }
    #else
        public func flatMap<U>(@noescape transform: Value -> Result<U, Error>) -> Result<U, Error> {
            return analysis(
                ifSuccess: transform,
                ifFailure: Result<U, Error>.Failure)
        }
    #endif

	/// Returns a new Result by mapping `Failure`'s values using `transform`, or re-wrapping `Success`es’ values.
    #if swift(>=3)
        public func mapError<Error2>(_ transform: @noescape (Error) -> Error2) -> Result<Value, Error2> {
            return flatMapError { .Failure(transform($0)) }
        }
    #else
        public func mapError<Error2>(@noescape transform: Error -> Error2) -> Result<Value, Error2> {
            return flatMapError { .Failure(transform($0)) }
        }
    #endif

	/// Returns the result of applying `transform` to `Failure`’s errors, or re-wrapping `Success`es’ values.
    #if swift(>=3)
        public func flatMapError<Error2>(_ transform: @noescape (Error) -> Result<Value, Error2>) -> Result<Value, Error2> {
            return analysis(
                ifSuccess: Result<Value, Error2>.Success,
                ifFailure: transform)
        }
    #else
        public func flatMapError<Error2>(@noescape transform: Error -> Result<Value, Error2>) -> Result<Value, Error2> {
            return analysis(
                ifSuccess: Result<Value, Error2>.Success,
                ifFailure: transform)
        }
    #endif
}

// MARK: - Operators

infix operator &&& {
	/// Same associativity as &&.
	associativity left

	/// Same precedence as &&.
	precedence 120
}

/// Returns a Result with a tuple of `left` and `right` values if both are `Success`es, or re-wrapping the error of the earlier `Failure`.
#if swift(>=3)
    public func &&& <L: ResultType, R: ResultType where L.Error == R.Error> (left: L, right: @autoclosure () -> R) -> Result<(L.Value, R.Value), L.Error> {
        return left.flatMap { left in right().map { right in (left, right) } }
    }
#else
    public func &&& <L: ResultType, R: ResultType where L.Error == R.Error> (left: L, @autoclosure right: () -> R) -> Result<(L.Value, R.Value), L.Error> {
        return left.flatMap { left in right().map { right in (left, right) } }
    }
#endif
