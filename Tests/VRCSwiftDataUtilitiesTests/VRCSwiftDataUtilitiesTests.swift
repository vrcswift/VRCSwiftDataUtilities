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
        return rst
    }
    
    private func buildData(bytes: [UInt8]) -> Data {
        var data = Data.init(count: bytes.count)
        
        for i in 0..<bytes.count {
            data[i] = bytes[i]
        }
        
        return data
    }
    
    func testMerger() {
        let datas = [
            buildData(bytes: [0x00, 0x01, 0x02, 0x03]),
            buildData(bytes: [0x04, 0x05, 0x06, 0x07]),
            buildData(bytes: [0x08, 0x09, 0x0a, 0x0b])
        ]
        
        XCTAssertEqual(
            MergeBufferBlocks(blocks: datas),
            buildData(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                              0x08, 0x09, 0x0a, 0x0b]))
                              
        let merger = VRCDataMerger()
        merger.push(data: buildData(bytes: [0x00, 0x01, 0x02, 0x03]))
        merger.push(data: buildData(bytes: [0x04, 0x05, 0x06, 0x07]))
        merger.push(data: buildData(bytes: [0x08, 0x09, 0x0a, 0x0b]))
        
        XCTAssertEqual(
            merger.merge(),
            buildData(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                              0x08, 0x09, 0x0a, 0x0b]))
        
        merger.reset()
        merger.push(data: buildData(bytes: [0x00, 0x01, 0x02, 0x03]))
        merger.push(data: buildData(bytes: [0x04, 0x05, 0x06, 0x07]))
        merger.push(data: buildData(bytes: [0x08, 0x09, 0x0a, 0x0b]))
        XCTAssertEqual(
            merger.merge(),
            buildData(bytes: [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                              0x08, 0x09, 0x0a, 0x0b]))
    }

    func testFetcher() {
        //  Data count.
        let count = 128
        
        //  init(data: Data)
        //  Fetch()
        var d = buildRandomData(count: count)
        var fetcher = VRCDataFetcher(data: d)
        
        for i in 0..<count {
            do {
                XCTAssertEqual(try fetcher.fetch(), d[i])
                XCTAssertEqual(fetcher.getRemainCount(), d.count - i - 1)
            }
        }
        
        //  reinit(data)
        //  fetchBytes()
        d = buildRandomData(count: count)
        fetcher.reinit(data: d)
        
        for i in 0..<Int(count/2) {
            do {
                XCTAssertEqual(
                    try fetcher.fetchBytes(count: 2),
                    d.subdata(in: (i * 2)..<((i + 1) * 2)))
            }
        }

        //  fetch()
        d = buildRandomData(count: count)
        fetcher = VRCDataFetcher(data: d)
        
        for i in 0..<count {
            do {
                XCTAssertEqual(try fetcher.fetch(), d[i])
            }
        }
        
        //  fetchAll()
        d = buildRandomData(count: count)
        fetcher.reinit(data: d)
        
        do {
            XCTAssertEqual(try fetcher.fetchAll(), d)
        }
    }
    
    func testBlockFetcher() {
        let data1 = buildData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                                      0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
                                      0x0f, 0x10, 0x11, 0x12, 0x13, 0x14])
                                     
        let data2 = buildData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                                      0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
                                      0x0f, 0x10, 0x11, 0x12, 0x13, 0x14])
                                      
        var fetcher = VRCBlockDataFetcher(blocks: [data1, data2])
        
        do {
            for i in 0..<data1.count {
                XCTAssertEqual(try fetcher.fetch(), data1[i])
            }
            for i in 0..<data2.count {
                XCTAssertEqual(try fetcher.fetch(), data2[i])
            }
        }
        
        do {
            let _ = try fetcher.fetch()
        } catch let error as VRCDataFetcherError {
            XCTAssertEqual(error.kind, .endOfStream)
        } catch _ {
            XCTFail("Invalid error.")
        }
        
        fetcher = VRCBlockDataFetcher(blocks: [data1, data2])
        
        do {
            XCTAssertEqual(
                try fetcher.fetchBytes(count: 7),
                buildData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))
            XCTAssertEqual(
                try fetcher.fetchBytes(count: 7),
                buildData(bytes: [0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e]))
            XCTAssertEqual(
                try fetcher.fetchBytes(count: 7),
                buildData(bytes: [0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x01]))
            XCTAssertEqual(
                try fetcher.fetchBytes(count: 13),
                buildData(bytes: [0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                                  0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e]))
            XCTAssertEqual(
                try fetcher.fetchBytes(count: 6),
                buildData(bytes: [0x0f, 0x10, 0x11, 0x12, 0x13, 0x14]))
        }
        
        do {
            let _ = try fetcher.fetchBytes(count: 10)
            XCTFail("Not throw expected error.")
        } catch let error as VRCDataFetcherError {
            XCTAssertEqual(error.kind, .endOfStream)
        } catch _ {
            XCTFail("Invalid error.")
        }
        
        fetcher = VRCBlockDataFetcher(blocks: [data1, data2])
        do {
            XCTAssertEqual(
                try fetcher.fetchAll(),
                buildData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
                                  0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10,
                                  0x11, 0x12, 0x13, 0x14, 0x01, 0x02, 0x03, 0x04,
                                  0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c,
                                  0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14]))
        }
        XCTAssertTrue(fetcher.isEnd())
        
        fetcher = VRCBlockDataFetcher(blocks: [data1, data2])
        
        do {
            XCTAssertEqual(
                try fetcher.fetchBytes(count: 7),
                buildData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))
            XCTAssertEqual(
                try fetcher.fetchAll(),
                buildData(bytes: [0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
                                  0x10, 0x11, 0x12, 0x13, 0x14, 0x01, 0x02, 0x03,
                                  0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b,
                                  0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13,
                                  0x14]))
        }
        
        fetcher.reinit(newBlocks: [data1, data2])
        do {
            XCTAssertEqual(
                try fetcher.fetchBytesAsBlocks(count: 23),
                [
                    buildData(bytes: [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                                      0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
                                      0x0f, 0x10, 0x11, 0x12, 0x13, 0x14]),
                    buildData(bytes: [0x01, 0x02, 0x03])
                ])
        }
        
        fetcher.reset()
        do {
            XCTAssertEqual(
                try fetcher.fetchAllAsBlocks(),
                [data1, data2])
        }
    }

    static var allTests = [
        ("testFetcher", testFetcher),
        ("testBlockFetcher", testBlockFetcher),
        ("testMerger", testMerger)
    ]
}
