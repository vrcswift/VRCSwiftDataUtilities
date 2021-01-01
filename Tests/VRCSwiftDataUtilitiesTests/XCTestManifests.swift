//
//  Copyright 2020 - 2021 The VRC Authors. All rights reserved.
//  Use of this source code is governed by a BSD-style license that can be
//  found in the LICENSE.md file.
//

import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VRCSwiftDataUtilitiesTests.allTests),
    ]
}
#endif
