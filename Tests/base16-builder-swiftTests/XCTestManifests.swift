import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(base16_builder_swiftTests.allTests)
    ]
}
#endif
