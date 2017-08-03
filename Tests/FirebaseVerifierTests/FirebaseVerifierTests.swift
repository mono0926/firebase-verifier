import XCTest
import FirebaseVerifier

class FirebaseVerifierTests: XCTestCase {
    private let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImIyYmRjZDkyNGZhNWI1ZThhYjkwNTQ3M2ZjZTYxMGU3MWU0MjJlNmQifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vaWdob3N0LWRldiIsInByb3ZpZGVyX2lkIjoiYW5vbnltb3VzIiwiYXVkIjoiaWdob3N0LWRldiIsImF1dGhfdGltZSI6MTUwMTM4MTc3OSwidXNlcl9pZCI6IkpscjhMWFcybmhQTlRuTnR1SmJZV0dFTjRhUjIiLCJzdWIiOiJKbHI4TFhXMm5oUE5Ubk50dUpiWVdHRU40YVIyIiwiaWF0IjoxNTAxNjU0ODI5LCJleHAiOjE1MDE2NTg0MjksImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnt9LCJzaWduX2luX3Byb3ZpZGVyIjoiYW5vbnltb3VzIn19.ptrdDsLRFC0zPfm-W-aeIswUshtyTPKA_I8P42qaJFBIc0QBfWh9JhnBFiEjjde79OY2uT-wTLOyMtoosiTOikZR4cDJA2N7IYR-z4Jgrj9ImAOQn9lzED0ftmBQIUBw0fhPC8oiDYjW24GAPRlW1dmn28TjClP2GqzzhDv563QrGg9lSbiakxSPtaEpx492NLeR0CShMptFaCpDyKH6xw3yzg6Xp1GbwSycNDry5fJs0QwO-tOyoPQ0YFUcxIW3mdeooxc0kOgr62wSWg2tf1Kc4_Qhcyk-PBrO1XmPd8KTD7Ix8npzNhW6KCBOcWtPZA-ffPOpBSrJno4p28C4Qg"
    private let projectId = "ighost-dev"
    private var verifier: FirebaseVerifier!
    override func setUp() {
        super.setUp()
        verifier = try! FirebaseJWTVerifier(projectId: projectId)
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
            XCTAssertEqual(result.authTime, Date(rfc1123: "Wed, 2 Aug 2017 07:20:29 GMT"))
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
