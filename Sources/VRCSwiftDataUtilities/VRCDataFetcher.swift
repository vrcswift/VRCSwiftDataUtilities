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
public struct VRCDataFetcherError: Error {
    enum VRCDataFetcherErrorType {
        case endOfStream
        case outOfRange
        case parameterError
    }
    
    let message: String
    let kind: VRCDataFetcherErrorType
}

extension VRCDataFetcherError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}

//
//  MARK: Classes.
//

///
///  Data fetcher
///
public class VRCDataFetcher {
    //
    //  MARK: VRCDataFetcher members.
    //
    
    var m_Data: Data
    
    var m_Position: Data.Index = 0
    
    //
    //  MARK: VRCDataFetcher constructor.
    //
    
    ///
    ///  Init with copying bytes.
    ///
    ///  - Parameter data: The data.
    ///
    public init(data: Data) {
        m_Data = data
    }
    
    //
    //  MARK: VRCDataFetcher public methods.
    //
    
    ///
    ///  Fetch one byte.
    ///
    ///  - Throws: Raised if there is no bytes.
    ///
    ///  - Returns: The byte.
    ///
    public func fetch() throws -> UInt8 {
        //  Check whether ended.
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
        }
        
        //  Get byte.
        let rst = m_Data[m_Position]
        
        //  Move position.
        m_Position += 1
        
        return rst
    }
    
    ///
    ///  Fetch all bytes.
    ///
    ///  - Throws: Raised if stream is ended.
    ///
    ///  - Returns: The bytes.
    ///
    public func fetchAll() throws -> Data {
        //  Check whether ended.
        if self.isEnd() {
            throw VRCDataFetcherError(message: "End of stream.", kind: .endOfStream)
        }
    
        //  Get buffer.
        let buf = m_Data.subdata(in: m_Position..<m_Data.count)
        
        //  Move position.
        m_Position = m_Data.count
        
        return buf
    }
    
    ///
    ///  Fetch bytes with specific count.
    ///
    ///  - Parameter count: The count
    ///
    ///  - Throws: Raised in the situations:
    ///
    ///         - The fetcher is already ended.
    ///         - The count is out of range.
    ///         - count < 0.
    ///
    ///  - Returns: The bytes.
    ///
    public func fetchBytes(count: Data.Index) throws -> Data {
        //  Check whether ended.
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
        }
        
        //  Check whether out of range.
        if count > self.getRemainCount() {
            throw VRCDataFetcherError(
                message: "Out of range.", kind: .outOfRange)
        }
        
        //  Check parameter(s).
        if count < 0 {
            throw VRCDataFetcherError(
                message: "count < 0.", kind: .parameterError)
        }
    
        //  Get buffer.
        let rst = m_Data.subdata(
            in: m_Position..<(min(m_Position + count, m_Data.count)))
        
        //  Move position.
        m_Position += rst.count
        
        return rst
    }
    
    ///
    ///  Skip specific bytes.
    ///
    ///  - Throws: Raised in the situations:
    ///
    ///         - The fetcher is already ended.
    ///         - The count of skipped bytes is out of range.
    ///         - steps < 0.
    ///
    ///  - Parameter step: The count of bytes to be skipped.
    ///
    public func skip(steps: Data.Index) throws {
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
        }
        
        if steps > self.getRemainCount() {
            throw VRCDataFetcherError(
                message: "Out of range.", kind: .outOfRange)
        }
        
        //  Check parameter(s).
        if steps < 0 {
            throw VRCDataFetcherError(
                message: "steps < 0.", kind: .parameterError)
        }
    
        //  Get skip steps.
        let skipped = min(steps, self.getRemainCount())
    
        //  Move position.
        m_Position += skipped
    }
    
    ///
    ///  Get count of remaining bytes.
    ///
    ///  - Returns: The count.
    ///
    public func getRemainCount() -> Data.Index {
        return m_Data.count - m_Position
    }
    
    ///
    ///  Check whether fetcher is end.
    ///
    ///  - Returns: True if so.
    ///
    public func isEnd() -> Bool {
        return m_Position == m_Data.count
    }
    
    ///
    ///  Reset position.
    ///
    public func reset() {
        m_Position = 0
    }
    
    ///
    ///  Reinit fetcher with copying data.
    ///
    ///  - Parameter data: The data.
    ///
    public func reinit(data: Data) {
        m_Data = data
        m_Position = 0
    }
}

///
///  Block data fetcher.
///
class VRCBlockDataFetcher {
    
    //
    //  MARK: VRCBlockDataFetcher members.
    //
    
    //  Fetcher list.
    private var m_Fetchers = [VRCDataFetcher]()
    
    //  Current fetcher index.
    private var m_CurrentFetcher = 0
    
    //  Remain count.
    private var m_RemainCount = 0
    
    //
    //  MARK: VRCBlockDataFetcher constructor.
    //
    
    ///
    ///  Constructor of block data fetcher.
    ///
    ///  - Parameter blocks: The blocks.
    ///
    public init(blocks: [Data]) {
        m_RemainCount = 0
    
        for data in blocks {
            if data.count == 0 {
                continue
            }
            m_Fetchers.append(VRCDataFetcher(data: data))
            m_RemainCount += data.count
        }
    }
    
    //
    //  MARK: VRCBlockDataFetcher public methods.
    //
    
    ///
    ///  Fetch one byte.
    ///
    ///  - Throws: Raised if there is no bytes.
    ///
    ///  - Returns: The byte.
    ///
    public func fetch() throws -> UInt8 {
        while m_CurrentFetcher < m_Fetchers.count {
            let fetcher = m_Fetchers[m_CurrentFetcher]
            do {
                //  Try to fetch byte.
                let byte = try fetcher.fetch()
                
                //  Set remain byte.
                m_RemainCount -= 1
                
                return byte
            } catch _ {
                //  Do nothing.
            }
            m_CurrentFetcher += 1
        }
        
        throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
    }
    
    ///
    ///  Fetch all bytes.
    ///
    ///  - Throws: Raised if stream is already ended.
    ///
    ///  - Returns: The bytes.
    ///
    public func fetchAll() throws -> Data {
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
        }
    
        let merger = VRCDataMerger()
        while m_CurrentFetcher < m_Fetchers.count {
            merger.push(data: try m_Fetchers[m_CurrentFetcher].fetchAll())
            m_CurrentFetcher += 1
        }
        
        //  Set remain count.
        m_RemainCount = 0
        
        return merger.merge()
    }
    
    ///
    ///  Fetch all remaining bytes as blocks.
    ///
    ///  - Throws if stream is already ended.
    ///
    ///  - Returns: The blocks.
    ///
    public func fetchAllAsBlocks() throws -> [Data] {
        
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
        }
        
        var out = [Data]()
        while m_CurrentFetcher < m_Fetchers.count {
            let fetcher = m_Fetchers[m_CurrentFetcher]
            let block = try fetcher.fetchAll()
            if block.count != 0 {
                out.append(block)
            }
            m_CurrentFetcher += 1
        }
        
        //  Set remain count.
        m_RemainCount = 0
        
        return out
    }

    ///
    ///  Fetch specific bytes.
    ///
    ///  - Parameter count: The bytes count.
    ///
    ///  - Throws: Raised in the situations:
    ///
    ///         - The stream is ended.
    ///         - The bytes count is out of range.
    ///         - count < 0.
    ///
    ///  - Returns: The bytes.
    ///
    public func fetchBytes(count: Data.Index) throws -> Data {
        //  Check whether ended.
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
        }
        
        if count > self.getRemainCount() {
            throw VRCDataFetcherError(
                message: "Out of range.", kind: .outOfRange)
        }
        
        //  Check parameter(s).
        if count < 0 {
            throw VRCDataFetcherError(
                message: "count < 0.", kind: .parameterError)
        }
        
        let out = VRCDataMerger()
        var remainCount = count
        while m_CurrentFetcher < m_Fetchers.count {
            //  Fetch bytes.
            let currentCount = min(
                remainCount, m_Fetchers[m_CurrentFetcher].getRemainCount())
            let data =
                try m_Fetchers[m_CurrentFetcher].fetchBytes(count: currentCount)
            
            //  Push to output buffer.
            out.push(data: data)
            
            //  Do statistics.
            remainCount -= currentCount
            m_RemainCount -= currentCount
            
            if remainCount == 0  {
                break
            }
            
            //  Move to next fetcher.
            m_CurrentFetcher += 1
        }

        //  Check whether current fetcher is ended.
        while m_CurrentFetcher < m_Fetchers.count {
            if m_Fetchers[m_CurrentFetcher].isEnd() {
                m_CurrentFetcher += 1
            } else {
                break
            }
        }
        
        return out.merge()
    }
    
    ///
    /// Fetch specific bytes as blocks.
    ///
    /// - Parameter count: The bytes count.
    ///
    /// - Throws: Raised in the situations:
    ///
    ///         - The stream is ended.
    ///         - The bytes count is larger than remain count.
    ///         - count < 0.
    ///
    /// - Returns: The buffer blocks.
    ///
    public func fetchBytesAsBlocks(count: Data.Index) throws -> [Data] {
        //  Check whether ended.
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
        }
        
        //  Check whether bytes count is out of range.
        if count > self.getRemainCount() {
            throw VRCDataFetcherError(
                message: "Out of range.", kind: .outOfRange)
        }
        
        //  Check parameter(s).
        if count < 0 {
            throw VRCDataFetcherError(
                message: "count < 0.", kind: .parameterError)
        }
        
        //  Create output buffer list.
        var bufferList = [Data]()
        
        //  Create remaining counter.
        var remainCount = count
        
        while m_CurrentFetcher < m_Fetchers.count {
            //  Try to read bytes.
            let currentCount = min(
                remainCount, m_Fetchers[m_CurrentFetcher].getRemainCount())
                
            //  Fetch buffer.
            let buffer =
                try m_Fetchers[m_CurrentFetcher].fetchBytes(count: currentCount)
            
            //  Insert bytes to output list.
            bufferList.append(buffer)
            remainCount -= currentCount
            m_RemainCount -= currentCount
            
            //  Stop if no more bytes should be read.
            if remainCount == 0 {
                break
            }
            
            //  Move to next feetcher.
            m_CurrentFetcher += 1
        }
        
        while m_CurrentFetcher < m_Fetchers.count {
            if m_Fetchers[m_CurrentFetcher].isEnd() {
                m_CurrentFetcher += 1
            } else {
                break
            }
        }
        
        return bufferList
    }

    ///
    /// Skip specific bytes.
    ///
    /// - Parameter steps: The count of bytes to be skipped.
    ///
    /// - Throws: Raised in the situations:
    ///
    ///         - The stream is ended.
    ///         - The count of bytes to be skipped is larger than remain count.
    ///         - steps < 0.
    ///
    public func skip(steps: Data.Index) throws {
        //  Check whether ended.
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStream)
        }
        
        //  Check whether step is out of range.
        if steps > self.getRemainCount() {
            throw VRCDataFetcherError(
                message: "Out of range.", kind: .outOfRange)
        }
        
        //  Check parameter(s).
        if steps < 0 {
            throw VRCDataFetcherError(
                message: "steps < 0.", kind: .parameterError)
        }
        
        var remainSteps = steps
        
        while m_CurrentFetcher < m_Fetchers.count {
            //  Try to skip steps.
            let currentSkipped = min(
                remainSteps, m_Fetchers[m_CurrentFetcher].getRemainCount())
            
            //  Skipped.
            try m_Fetchers[m_CurrentFetcher].skip(steps: currentSkipped)
                
            //  Do statistics.
            remainSteps -= currentSkipped
            m_RemainCount -= currentSkipped
            
            //  Stop if there is no remaining steps.
            if remainSteps == 0 {
                break
            }
        
            //  Move to next fetcher.
            m_CurrentFetcher += 1
        }
        
        //  Check whether current fetcher is ended.
        while m_CurrentFetcher < m_Fetchers.count {
            if m_Fetchers[m_CurrentFetcher].isEnd() {
                m_CurrentFetcher += 1
            } else {
                break
            }
        }
    }
    
    ///
    ///  Get count of remaining bytes.
    ///
    ///  - Returns: The count.
    ///
    public func getRemainCount() -> Data.Index {
        return m_RemainCount
    }
    
    ///
    /// Get whether cursor reached the end.
    ///
    /// - Returns: True if ended.
    ///
    public func isEnd() -> Bool {
        return m_RemainCount == 0
    }
    
    ///
    ///  Reset cursor.
    ///
    public func reset() {
        m_RemainCount = 0
    
        for fetcher in m_Fetchers {
            fetcher.reset()
            m_RemainCount += fetcher.getRemainCount()
        }
        
        m_CurrentFetcher = 0
    }
    
    ///
    ///  Reinitialize object.
    ///
    /// - Parameter newBlocks: New blocks.
    ///
    public func reinit(newBlocks: [Data]) {
        //  Set blocks.
        var blocks = [Data]()
        for b in newBlocks {
            if b.count != 0 {
                blocks.append(b)
            }
        }
        
        //  Reinitialize fetchers.
        let oldBlocksCount = m_Fetchers.count
        let newBlocksCount = blocks.count
        if oldBlocksCount != newBlocksCount {
            if (newBlocksCount > oldBlocksCount) {
                for i in 0..<oldBlocksCount {
                    m_Fetchers[i].reinit(data: blocks[i])
                }
                for i in oldBlocksCount..<newBlocksCount {
                    m_Fetchers.append(VRCDataFetcher(data: blocks[i]))
                }
            } else {
                m_Fetchers.removeSubrange(newBlocksCount..<oldBlocksCount)
                for i in 0..<m_Fetchers.count {
                    m_Fetchers[i].reinit(data: blocks[i])
                }
            }
        } else {
            for i in 0..<m_Fetchers.count {
                m_Fetchers[i].reinit(data: blocks[i])
            }
        }
        
        //  Reset cursor.
        m_CurrentFetcher = 0
        
        //  Reset remain count.
        m_RemainCount = 0
        for fetcher in m_Fetchers {
            m_RemainCount += fetcher.getRemainCount()
        }
    }
}
