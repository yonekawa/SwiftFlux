//
//  EventEmitterSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/2/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Box
import Result
import SwiftFlux

class EventEmitterSpec: QuickSpec {
    struct EventEmitterTestStore: Store {
        static let instance = EventEmitterTestStore()
        enum TestEvent {
            case List
            case Created
        }
        typealias Event = TestEvent
    }
    struct EventEmitterTestStore2: Store {
        static let instance = EventEmitterTestStore2()
        enum TestEvent {
            case List
            case Created
        }
        typealias Event = TestEvent
    }

    override func spec() {
        let emitter = EventEmitter<EventEmitterTestStore>()
        let emitter2 = EventEmitter<EventEmitterTestStore2>()

        describe("emit") {
            var listeners = [String]()
            var results = [String]()

            beforeEach({ () -> () in
                listeners = []
                let id1 = emitter.listen(EventEmitterTestStore.Event.List, handler: { () -> Void in
                    results.append("test list")
                })
                let id2 = emitter2.listen(EventEmitterTestStore2.Event.List, handler: { () -> Void in
                    results.append("test2 list")
                })
                let id3 = emitter.listen(EventEmitterTestStore.Event.Created, handler: { () -> Void in
                    results.append("test created")
                })
                listeners.append(id1)
                listeners.append(id2)
                listeners.append(id3)
            })

            afterEach({ () -> () in
                for listener in listeners {
                    emitter.unlisten(listener)
                }
            })
            
            it("should fire event correctly") {
                emitter.emit(EventEmitterTestStore.Event.List)
                expect(results.count).to(equal(1))
                expect(results[0]).to(equal("test list"))
 
                emitter.emit(EventEmitterTestStore.Event.List)
                expect(results.count).to(equal(2))
                expect(results[1]).to(equal("test list"))

                emitter2.emit(EventEmitterTestStore2.Event.List)
                expect(results.count).to(equal(3))
                expect(results[2]).to(equal("test2 list"))

                emitter.emit(EventEmitterTestStore.Event.Created)
                expect(results.count).to(equal(4))
                expect(results[3]).to(equal("test created"))

                emitter.unlisten(listeners[2])
                emitter.emit(EventEmitterTestStore.Event.Created)
                expect(results.count).to(equal(4))
            }
        }
    }
}