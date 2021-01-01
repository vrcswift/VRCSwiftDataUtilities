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
//  MARK: Classes.
//

///
///  Data merger.
///
public class VRCDataMerger {
    
    //
    //  MARK: VRCDataMerger members.
    //
    
    //  The pushed data.
    var m_Datas = [Data]()
    
    //
    //  MARK: VRCDataMerger constructor.
    //
    public init() {
        //  Do nothing.
    }
    
    //
    //  MARK: VRCDataMerger public methods.
    //
    
    ///
    ///  Push a data object.
    ///
    ///  - Parameter data: The data.
    ///
    public func push(data: Data) {
        m_Datas.append(data)
    }
    
    ///
    /// Merge pushed data.
    ///
    /// - Returns: The data.
    ///
    public func merge() -> Data {
        var rstlen = 0
        
        for data in m_Datas {
            rstlen += data.count
        }
        
        var rst = Data.init(capacity: rstlen)
        
        for data in m_Datas {
            rst += data
        }

        return rst
    }
    
    ///
    ///  Clear pushed data.
    ///
    public func reset() {
        m_Datas.removeAll()
    }
}

//
//  MARK: Public functions.
//

///
///  Merge data blocks to one data object.
///
///  - Parameter blocks: The blocks to be concatencated.
///
///  - Returns: The concatencated buffer.
///
public func MergeBufferBlocks(blocks: [Data]) -> Data {
    let blocklen = blocks.count;
    
    if blocklen == 1 {
        return blocks[0]
    } else if blocklen == 0 {
        return Data.init(count: 0)
    } else {
        let merger = VRCDataMerger()
        for data in blocks {
            merger.push(data: data)
        }
        return merger.merge()
    }
}
