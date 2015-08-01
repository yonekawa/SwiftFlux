//
//  EventEmitter.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/1/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation

public struct EventEmitter {
    static public func listen<T: Store>(store: T, event: T.Event, handler: () -> Void) {
    }

    static public func unlisten<T: Store>(store: T, event: T.Event, handler: () -> Void) {
    }

    static public func emit<T: Store>(store: T, event: T.Event) {
    }
}