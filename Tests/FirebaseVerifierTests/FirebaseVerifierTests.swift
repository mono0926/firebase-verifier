import XCTest
import FirebaseVerifier

struct PublicCertificateFetcherStub: PublicCertificateFetcher {
    func fetch(with keyIdentifier: String) throws -> String {
        return "MIIDHDCCAgSgAwIBAgIIblyb+nkoC9kwDQYJKoZIhvcNAQEFBQAwMTEvMC0GA1UEAxMmc2VjdXJldG9rZW4uc3lzdGVtLmdzZXJ2aWNlYWNjb3VudC5jb20wHhcNMTcwODE1MDA0NTI2WhcNMTcwODE4MDExNTI2WjAxMS8wLQYDVQQDEyZzZWN1cmV0b2tlbi5zeXN0ZW0uZ3NlcnZpY2VhY2NvdW50LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANIO54IsAHgPQ3BZvDsOXIptiaGSNkC1miCtHWQ654IDsq4yLO5j9MWj/tZ/7sp7Pi/KJskMebda5L9/7OaI6CIxVt33vcCXC+E2v3AHusnVsETXbNE3Az5xcLpclaAM4nCFcvMnQocKX5WAuAs7qJW4AfyhnjrGTcs0ULGPtNCdAYWC8+QNcwYJleZMA+YoudGURvt14Ycd2FU5sjDbOCtzthQAgQqbsE2tJRIMn2qn66favsC/2SXd8bwMbKZp0StkXPHZ/pu6KD5ueqrR++yGQNxJVWPLyjSmoezqrYEOCkc25wXoQ7O2ACofI6ter27BcDuDUjCHYRLKLN+qUSUCAwEAAaM4MDYwDAYDVR0TAQH/BAIwADAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwIwDQYJKoZIhvcNAQEFBQADggEBAA8mLZm5/8jQ4Yeex0WLYiydCjveBW8L/BIuM+5CPLEBJtKhn54Vk/KsqXETS6/qOEOvTrYkE04e6h8U0DQHKeRcUFniI1uonK2mbKaAlJCNqdzE/29y8m9Jcf6XlfgXWG3nf6Ie0qLLgzLNFs7GsR3YFHDnpREI9mH7v59WVo2lek+gQ6gSgHAR7EUFhvZIWq1FA7DsuK44VEaCqcFRpr8W6N5prui1I+fhCHRH8GBzaaE+RU/SX7F+uLjq26/UNlmFGuoVrzpxBs/PyZTacNxQ9FXa7qbQQLkUU3mVC4DQ8CnvdqZoHSW9wup7NwbXgR+ciPDm5y8maIUWS23JCxY="
    }
}

class FirebaseVerifierTests: XCTestCase {
    private let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjMxMjNlMWE3ZTY5MTEyNTI4NDQ2M2ZjOWJmNmEyNGM0YmVkOGQ5NTIifQ.eyJpc3MiOiJodHRwczovL3NlY3VyZXRva2VuLmdvb2dsZS5jb20vaWdob3N0LWRldiIsImF1ZCI6ImlnaG9zdC1kZXYiLCJhdXRoX3RpbWUiOjE1MDI4NTI3NTgsInVzZXJfaWQiOiJVMXN5bkxzRzFOTUFnS0IwZk5qZXVsSXBsZGYxIiwic3ViIjoiVTFzeW5Mc0cxTk1BZ0tCMGZOamV1bElwbGRmMSIsImlhdCI6MTUwMjg1Mjc1OCwiZXhwIjoxNTAyODU2MzU4LCJlbWFpbCI6Im1vbm8wOTI2QGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJmYWNlYm9vay5jb20iOlsiMTAyMTE0Njk0MTY3MDQyOTUiXSwiZW1haWwiOlsibW9ubzA5MjZAZ21haWwuY29tIl19LCJzaWduX2luX3Byb3ZpZGVyIjoiZmFjZWJvb2suY29tIn19.GlawQ9T0M-3lvilttUwh7wuT7e3c5aPCKibOfdYIAZ2HNCZ7pPr2xuyeLMVQsp5iMZ_zlkd82QFTkf2GnJOzRu1c537QbdcJWjKf5-lgcYNb-UprjPfKM0trbVU6DkzxJKUWVaBHV6yEOf-9ESj7_fiqnwizTZQWACf5qD1dHTx27cS1cGboTyZ9FxgpPmiuEdH5tdOCAb8ekdDAPmHr7CMDMSSEOh7BsqRB3-EV9NaXgTAXwi5NoAyycxTYMBe_Y_HjlifAx18J5Tqq2ZVw0IiSMUB1z8Ph8IZ7Bf3HIZSj5HS14JBlLckrZAGO-bwkszSd9z2YVhYEvJMZuQ4LbA"
    private let projectId = "ighost-dev"
    private var verifier: FirebaseVerifier!
    override func setUp() {
        super.setUp()
        verifier = try! FirebaseJWTVerifier(projectId: projectId, publicCertificateFetcher: PublicCertificateFetcherStub())
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
            let user = try verifier.verify(token: token, allowExpired: true)
            XCTAssertEqual(user.id, "U1synLsG1NMAgKB0fNjeulIpldf1")
            XCTAssertEqual(user.authTime, Date(rfc1123: "Wed, 16 Aug 2017 03:05:58 GMT"))
            XCTAssertEqual(user.issuedAtTime, Date(rfc1123: "Wed, 16 Aug 2017 03:05:58 GMT"))
            XCTAssertEqual(user.expirationTime, Date(rfc1123: "Wed, 16 Aug 2017 04:05:58 GMT"))
            XCTAssertEqual(user.email, "mono0926@gmail.com")
            XCTAssertEqual(user.emailVerified, false)
            let firebase = user.firebase
            XCTAssertNotNil(firebase)
            XCTAssertEqual(firebase.signInProvider, "facebook.com")
            let identities = firebase.identities
            XCTAssertEqual(identities.count, 2)
            XCTAssertEqual(identities["facebook.com"]!, ["10211469416704295"])
            XCTAssertEqual(identities["email"]!, ["mono0926@gmail.com"])
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
