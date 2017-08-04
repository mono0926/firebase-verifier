# FirebaseVerifier

```swift
do {
    let verifier = try FirebaseVerifier(projectId: "YOUR_PROJECT_ID")
    let user = try verifier.verify(token: "FIREBASE_USER_TOKEN")
    print(user.id)
    print(user.authTime)
} catch let e {
    print(e)
}
```