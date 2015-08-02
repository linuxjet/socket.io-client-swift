//
//  AbstractSocketTest.swift
//  Socket.IO-Client-Swift
//
//  Created by Lukas Schmidt on 02.08.15.
//
//

import XCTest

class AbstractSocketTest: XCTestCase {
    static let TEST_TIMEOUT = 4.0
    var socket:SocketIOClient!
    var testKind:TestKind?
    
    override func tearDown() {
        super.tearDown()
        socket.close(fast: false)
    }
    
    func openConnection() {
        let expection = self.expectationWithDescription("connect")
        socket.on("connect") {data, ack in
            expection.fulfill()
        }
        socket.connect()
        XCTAssertTrue(socket.connecting)
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func generateTestName(rawTestName:String) ->String {
        return rawTestName + testKind!.rawValue
    }
    
    func checkConnectionStatus() {
        XCTAssertTrue(socket.connected)
        XCTAssertFalse(socket.connecting)
        XCTAssertFalse(socket.reconnecting)
        XCTAssertFalse(socket.closed)
        XCTAssertFalse(socket.secure)
    }
    
    func socketMultipleEmit(testName:String, emitData:Array<AnyObject>, callback:NormalCallback){
        let finalTestname = generateTestName(testName)
        let expection = self.expectationWithDescription(finalTestname)
        func didGetEmit(result:NSArray?, ack:AckEmitter?) {
            callback(result, ack)
            expection.fulfill()
        }
        
        socket.emit(finalTestname, withItems: emitData)
        socket.on(finalTestname + "Return", callback: didGetEmit)
        waitForExpectationsWithTimeout(SocketEmitTest.TEST_TIMEOUT, handler: nil)
    }
    
    
    func socketEmit(testName:String, emitData:AnyObject?, callback:NormalCallback){
        let finalTestname = generateTestName(testName)
        let expection = self.expectationWithDescription(finalTestname)
        func didGetEmit(result:NSArray?, ack:AckEmitter?) {
            callback(result, ack)
            expection.fulfill()
        }
        
        socket.on(finalTestname + "Return", callback: didGetEmit)
        if let emitData = emitData {
            socket.emit(finalTestname, emitData)
        } else {
            socket.emit(finalTestname)
        }
        
        waitForExpectationsWithTimeout(SocketEmitTest.TEST_TIMEOUT, handler: nil)
    }
    
    func socketAcknwoledgeMultiple(testName:String, Data:Array<AnyObject>, callback:NormalCallback){
        let finalTestname = generateTestName(testName)
        let expection = self.expectationWithDescription(finalTestname)
        func didGetResult(result:NSArray?) {
            callback(result, nil)
            expection.fulfill()
        }
        
        socket.emitWithAck(finalTestname, withItems: Data)(timeoutAfter: 5, callback: didGetResult)
        waitForExpectationsWithTimeout(SocketEmitTest.TEST_TIMEOUT, handler: nil)
    }
    
    func socketAcknwoledge(testName:String, Data:AnyObject?, callback:NormalCallback){
        let finalTestname = generateTestName(testName)
        let expection = self.expectationWithDescription(finalTestname)
        func didGet(result:NSArray?) {
            callback(result, nil)
            expection.fulfill()
        }
        var ack:OnAckCallback!
        if let Data = Data {
            ack = socket.emitWithAck(finalTestname, Data)
        } else {
            ack = socket.emitWithAck(finalTestname)
        }
        ack(timeoutAfter: 20, callback: didGet)
        
        waitForExpectationsWithTimeout(SocketEmitTest.TEST_TIMEOUT, handler: nil)
    }
}
