//
//  Copyright 2020 - 2021 The VRC Authors. All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE.md file.
//

//
//  MARK: Imports.
//
import Foundation

//
//  MARK: Defines.
//

///
///  Fetcher error object.
///
public struct VRCDataQueueError: Error {
    enum VRCDataFetcherErrorType {
        case endOfStream
        case outOfRange
        case parameterError
        case bug
    }
    
    let message: String
    let kind: VRCDataFetcherErrorType
}

extension VRCDataQueueError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}

//
//  MARK: VRCDataQueue classes.
//

///
///  Data queue.
///
public class VRCDataQueue {
    //
    //  MARK: VRCDataQueue members.
    //
    var m_Remaining: Int = 0
    var m_Queue = [VRCDataFetcher]()
    
    //
    //  MARK: VRCDataQueue constructor.
    //
    
    ///
    ///  Construct the object.
    ///
    public init() {
        //  Do nothing.
    }
    
    //
    //  MARK: VRCDataQueue public methods.
    //

    ///
    ///  Push data to queue.
    ///
    ///  - Parameter data: The data.
    ///
    public func push(data: Data) {
        if data.isEmpty {
            return
        }
        
        self.m_Queue.append(VRCDataFetcher(data: data))
        self.m_Remaining += data.count
    }

    ///
    ///  Pop data from queue.
    ///
    ///  - Parameter count: The count of data.
    ///
    ///  - Throws: Raised in the situations:
    ///
    ///         - The count is out of range.
    ///         - count < 0.
    ///
    ///  - Returns: The data.
    ///
    public func pop(count: Int) throws -> Data {
        if count > self.m_Remaining {
            throw VRCDataQueueError(message: "Out of range.", kind: .outOfRange)
        }
        //  Check parameter(s).
        if count < 0 {
            throw VRCDataQueueError(
                message: "count < 0.", kind: .parameterError)
        }
        
        var data = [Data]()
        var cursor = 0
        while cursor < count {
            let needed = count - cursor
            guard let fetcher = self.m_Queue.first else {
                throw VRCDataQueueError(message: "Cannot get the fetcher in queue front", kind: .bug)
            }
            if fetcher.isEnd() {
                self.m_Queue.removeFirst()
                continue
            }
            
            let fetcherRemaining = fetcher.getRemainCount()
            if fetcherRemaining <= needed {
                data.append(try! fetcher.fetchAll())
                cursor += fetcherRemaining
                self.m_Queue.removeFirst()
                continue
            } else {
                data.append(try! fetcher.fetchBytes(count: needed))
                cursor += needed
                continue
            }
        }
        
        self.m_Remaining -= count
        return MergeBufferBlocks(blocks: data)
    }

    ///
    ///  Pop all data from queue.
    ///
    ///  - Returns: The data.
    ///
    public func popAll() -> Data {
        var data = [Data]()
        
        for fetcher in self.m_Queue {
            do {
                data.append(try fetcher.fetchAll())
            } catch _ {
                //  Do nothing.
            }
        }
        
        self.m_Queue.removeAll()
        self.m_Remaining = 0
        return MergeBufferBlocks(blocks: data)
    }
    
    ///
    ///  Get the remaining count
    ///
    ///  - Returns: The remaining count.
    ///
    public func getRemainCount() -> Int {
        return self.m_Remaining
    }

    ///
    ///  Reset the queue.
    ///
    public func reset() {
        self.m_Queue.removeAll()
        self.m_Remaining = 0
    }
    
}
