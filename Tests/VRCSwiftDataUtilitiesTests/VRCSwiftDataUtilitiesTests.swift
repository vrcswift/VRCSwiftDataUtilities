//
//  Copyright 2020 The VRC Authors. All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE.md file.
//

import XCTest
@testable import VRCSwiftDataUtilities

final class VRCSwiftDataUtilitiesTests: XCTestCase {
    private func buildRandomData(count: Data.Index = 64) -> Data {
        var rst = Data()
        for _ in 0..<count {
            rst.append(UInt8.random(in: UInt8.min...UInt8.max))
        }
        print(rst)
        return rst
    }

    func testBasic() {
        //  Data count.
        let count = 128
        
        //  init(data: Data)
        //  Fetch()
        var d = buildRandomData(count: count)
        var fetcher = VRCDataFetcher(data: d)
        
        for i in 0..<count {
            do {
                XCTAssertEqual(try fetcher.fetch(), d[i])
            }
        }
        
        //  reinit(data)
        //  fetchBytes()
        d = buildRandomData(count: count)
        fetcher.reinit(data: d)
        
        for i in 0..<Int(count/2) {
            XCTAssertEqual(
                fetcher.fetchBytes(count: 2),
                d.subdata(in: (i * 2)..<((i + 1) * 2)))
        }

        //  init(dataNoCopy)
        //  fetch()
        d = buildRandomData(count: count)
        fetcher = VRCDataFetcher(dataNoCopy: d)
        
        for i in 0..<count {
            do {
                XCTAssertEqual(try fetcher.fetch(), d[i])
            }
        }
        
        //  reinit(dataNoCopy)
        //  fetchAll()
        d = buildRandomData(count: count)
        fetcher.reinit(dataNoCopy: d)
        
        XCTAssertEqual(fetcher.fetchAll(), d)
        
    }

    static var allTests = [
        ("testBasic", testBasic)
    ]
}
