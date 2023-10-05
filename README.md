# Locking
NSLock wrapper for Swift

## Protected
```swift
private var state = Protected(State.resumed)
let _ = state.value
```

## sync
```swift
state.sync { state in
  state = .resumed
}
```
