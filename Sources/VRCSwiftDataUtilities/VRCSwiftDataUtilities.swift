//
//  Copyright 2020 The VRC Authors. All rights reserved.
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
        case endOfStreamError
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
    
    ///
    ///  Init with copying bytes.
    ///
    ///  - Parameter data: The data.
    ///
    init(data: Data) {
        m_Data = data.withUnsafeBytes { (raw) -> Data in
            return Data.init(bytes: raw.baseAddress!, count: raw.count)
        }
    }
    
    ///
    ///  Init without copying bytes.
    ///
    ///  - Parameter data: The data.
    ///
    init(dataNoCopy data: Data) {
        m_Data = data
    }
    
    ///
    ///  Fetch one byte.
    ///
    ///  - Throws: Raised if there is no bytes.
    ///
    ///  - Returns: The byte.
    ///
    public func fetch() throws -> UInt8 {
        //  Check whether is end.
        if self.isEnd() {
            throw VRCDataFetcherError(
                message: "End of stream.", kind: .endOfStreamError)
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
    ///  - Returns: The bytes.
    ///
    public func fetchAll() -> Data {
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
    ///  - Returns: The bytes.
    ///
    public func fetchBytes(count: Data.Index) -> Data {
        //  Get buffer.
        let rst = m_Data.subdata(
            in: m_Position..<(m_Position + min(count, m_Data.count)))
        
        //  Move position.
        m_Position += rst.count
        
        return rst
    }
    
    ///
    ///  Check whether fetcher is end.
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
    /// - Parameter data: The data.
    ///
    public func reinit(data: Data) {
        m_Data = data.withUnsafeBytes { (raw) -> Data in
            return Data.init(bytes: raw.baseAddress!, count: raw.count)
        }
        m_Position = 0
    }

    ///
    ///  Reinit fetcher without copying the bytes.
    ///
    ///  - Parameter data: The data.
    ///
    public func reinit(dataNoCopy data: Data) {
        m_Data = data
        m_Position = 0
    }
}
