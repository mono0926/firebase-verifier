# FirebaseVerifier

```swift
do {
    let verifier = try FirebaseVerifier(projectId: "YOUR_PROJECT_ID")
    let result = try verifier.verify(token: "FIREBASE_USER_TOKEN")
    print(result.userId)
    print(result.authTime)
} catch let e {
    print(e)
}
```