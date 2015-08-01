//
//  DispatcherTest.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/2/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Result
import Nimble
import Quick
import SwiftFlux

class DispatcherSpec: QuickSpec {
    override func spec() {
        it("should be disabled and not executing after initialization") {
            expect(true).to(beFalsy())
        }
    }
}