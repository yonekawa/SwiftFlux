//  Copyright (c) 2015 Rob Rix. All rights reserved.

import XCTest
@testable import SwiftFlux

final class ResultTests: XCTestCase {
	func testMapTransformsSuccesses() {
		XCTAssertEqual(success.map { $0.characters.count } ?? 0, 7)
	}

	func testMapRewrapsFailures() {
		XCTAssertEqual(failure.map { $0.characters.count } ?? 0, 0)
	}

	func testInitOptionalSuccess() {
		XCTAssert(Result("success" as String?, failWith: error) == success)
	}

	func testInitOptionalFailure() {
		XCTAssert(Result(nil, failWith: error) == failure)
	}


	// MARK: Errors

	func testErrorsIncludeTheSourceFile() {
        #if swift(>=2.2)
            let file = #file
        #else
            let file = __FILE__
        #endif
		XCTAssert(Result<(), NSError>.error().file == file)
	}

	func testErrorsIncludeTheSourceLine() {
        #if swift(>=2.2)
            let (line, error) = (#line, Result<(), NSError>.error())
        #else
            let (line, error) = (__LINE__, Result<(), NSError>.error())
        #endif
		XCTAssertEqual(error.line ?? -1, line)
	}

	func testErrorsIncludeTheCallingFunction() {
        #if swift(>=2.2)
            let function = #function
        #else
            let function = __FUNCTION__
        #endif
		XCTAssert(Result<(), NSError>.error().function == function)
	}

	// MARK: Try - Catch
	
	func testTryCatchProducesSuccesses() {
		let result: Result<String, NSError> = Result(try tryIsSuccess("success"))
		XCTAssert(result == success)
	}
	
	func testTryCatchProducesFailures() {
		let result: Result<String, NSError> = Result(try tryIsSuccess(nil))
		XCTAssert(result.error == error)
	}

	func testMaterializeProducesSuccesses() {
		let result1 = materialize(try tryIsSuccess("success"))
		XCTAssert(result1 == success)

        #if swift(>=3)
        #else
            let result2 = materialize { try tryIsSuccess("success") }
            XCTAssert(result2 == success)
        #endif
	}

	func testMaterializeProducesFailures() {
		let result1 = materialize(try tryIsSuccess(nil))
		XCTAssert(result1.error == error)

        #if swift(>=3)
        #else
            let result2 = materialize { try tryIsSuccess(nil) }
            XCTAssert(result2.error == error)
        #endif
	}

	// MARK: Cocoa API idioms

	func testTryProducesFailuresForBooleanAPIWithErrorReturnedByReference() {
		let result = `try` { attempt(true, succeed: false, error: $0) }
		XCTAssertFalse(result ?? false)
		XCTAssertNotNil(result.error)
	}

	func testTryProducesFailuresForOptionalWithErrorReturnedByReference() {
		let result = `try` { attempt(1, succeed: false, error: $0) }
		XCTAssertEqual(result ?? 0, 0)
		XCTAssertNotNil(result.error)
	}

	func testTryProducesSuccessesForBooleanAPI() {
		let result = `try` { attempt(true, succeed: true, error: $0) }
		XCTAssertTrue(result ?? false)
		XCTAssertNil(result.error)
	}

	func testTryProducesSuccessesForOptionalAPI() {
		let result = `try` { attempt(1, succeed: true, error: $0) }
		XCTAssertEqual(result ?? 0, 1)
		XCTAssertNil(result.error)
	}

	// MARK: Operators

	func testConjunctionOperator() {
		let resultSuccess = success &&& success
		if let (x, y) = resultSuccess.value {
			XCTAssertTrue(x == "success" && y == "success")
		} else {
			XCTFail()
		}

		let resultFailureBoth = failure &&& failure2
		XCTAssert(resultFailureBoth.error == error)

		let resultFailureLeft = failure &&& success
		XCTAssert(resultFailureLeft.error == error)

		let resultFailureRight = success &&& failure2
		XCTAssert(resultFailureRight.error == error2)
	}
}


// MARK: - Fixtures

let success = Result<String, NSError>.Success("success")
let error = NSError(domain: "com.antitypical.Result", code: 1, userInfo: nil)
let error2 = NSError(domain: "com.antitypical.Result", code: 2, userInfo: nil)
let failure = Result<String, NSError>.Failure(error)
let failure2 = Result<String, NSError>.Failure(error2)


// MARK: - Helpers

#if swift(>=3)
    func attempt<T>(_ value: T, succeed: Bool, error: NSErrorPointer) -> T? {
        if succeed {
            return value
        } else {
//            error!.memory = Result<(), NSError>.error()
            return nil
        }
    }
#else
    func attempt<T>(value: T, succeed: Bool, error: NSErrorPointer) -> T? {
        if succeed {
            return value
        } else {
            error.memory = Result<(), NSError>.error()
            return nil
        }
    }
#endif

#if swift(>=3)
    func tryIsSuccess(_ text: String?) throws -> String {
        guard let text = text else {
            throw error
        }
        
        return text
    }
#else
    func tryIsSuccess(text: String?) throws -> String {
        guard let text = text else {
            throw error
        }

        return text
    }
#endif

extension NSError {
	var function: String? {
		return userInfo[Result<(), NSError>.functionKey as NSString] as? String
	}
	
	var file: String? {
		return userInfo[Result<(), NSError>.fileKey as NSString] as? String
	}

	var line: Int? {
		return userInfo[Result<(), NSError>.lineKey as NSString] as? Int
	}
}
