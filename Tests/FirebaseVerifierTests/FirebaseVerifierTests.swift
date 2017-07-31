import XCTest
@testable import FirebaseVerifier

class FirebaseVerifierTests: XCTestCase {
    private let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijk5YmY1YTM4NWE3YmFiZGFiNTkwMDA4OTM2YjJlNjc2ZGFiMzgxNTkifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vaWdob3N0LWRldiIsInByb3ZpZGVyX2lkIjoiYW5vbnltb3VzIiwiYXVkIjoiaWdob3N0LWRldiIsImF1dGhfdGltZSI6MTUwMTM4MTc3OSwidXNlcl9pZCI6IkpscjhMWFcybmhQTlRuTnR1SmJZV0dFTjRhUjIiLCJzdWIiOiJKbHI4TFhXMm5oUE5Ubk50dUpiWVdHRU40YVIyIiwiaWF0IjoxNTAxMzkyNzUxLCJleHAiOjE1MDEzOTYzNTEsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnt9LCJzaWduX2luX3Byb3ZpZGVyIjoiYW5vbnltb3VzIn19.QY9Z9LgWxfPWxrF94doK6sIB0uJvEvlbVFdM05WINp5o2rWhL_VxNejFmNQYNx1vGmVfy8V1xJ-dlHL0TCsj4lDSiLWHiy75SGrN-5ciQ5c5Zowl_0_4UtBR5eswLEKsPkOrCMWEHZoX3iMJOMDKl4lDrFKVD-jesylIlcTCPZVwwVm16LWpOEf5FrjM7oRpsc95ZJwAIdqk5JVHmQDpJahLNA9OcmZtydToGscVbiQm4UynNgyWE3LARN8ux0D7MOJ42yrTnAHDuvJSpaiFoDFHVE_jAyT7sQNc4C6vBNS_UrkP7xIcqBNjAGTwre1-XfFs7cgRTsKQ8kxY47v3Sw"
    private let projectId = "ighost-dev"
    private var verifier: FirebaseVerifier!
    override func setUp() {
        super.setUp()
        verifier = try! FirebaseVerifier(projectId: projectId)
    }
    func testVerify() {
        do {
            _ = try verifier.verify(token: token)
        } catch let e as VerificationError {
            if case .expirationTimeIsPast = e.type {
                print(e)
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    func testVerify_allowExpired() {
        do {
            let result = try verifier.verify(token: token, allowExpired: true)
            XCTAssertEqual(result.userId, "Jlr8LXW2nhPNTnNtuJbYWGEN4aR2")
            XCTAssertEqual(result.authTime, Date(rfc1123: "Sun, 30 Jul 2017 06:32:31 GMT"))
        } catch let e {
            print(e)
            XCTFail()
        }
    }


    static var allTests = [
        ("testVerify", testVerify),
        ("testVerify_allowExpired", testVerify_allowExpired),
    ]
}
