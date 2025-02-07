//
//  Locking.swift
//  Locking
//
//  Created by CodingIran on 2023/10/05.
//
import Foundation

// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.5)
#error("Locking doesn't support Swift versions below 5.5.")
#endif

/// Current Locking version 0.0.5. Necessary since SPM doesn't use dynamic libraries. Plus this will be more accurate.
let version = "0.0.5"

public typealias SendableLocking = NSLocking & Sendable

public final class Protected<T> {
    public init(_ data: T, using lock: SendableLocking = NSLock()) {
        _data = data
        self.lock = lock
    }

    public var value: T {
        get {
            lock.sync {
                _data
            }
        }
        set {
            lock.sync {
                _data = newValue
            }
        }
    }

    public func sync<U>(_ body: (inout T) throws -> U) rethrows -> U {
        try lock.sync {
            var d = _data
            let result = try body(&d)
            _data = d
            return result
        }
    }

    public func sync(_ body: (inout T) throws -> Void) rethrows {
        try lock.sync {
            var d = _data
            try body(&d)
            _data = d
        }
    }

#if compiler(>=6)
    private nonisolated(unsafe) var _data: T
#else
    private var _data: T
#endif

    private let lock: SendableLocking
}

extension Protected: Sendable {}

public extension NSLocking {
    func sync<T>(_ block: () throws -> T) rethrows -> T {
        lock()
        defer {
            unlock()
        }
        return try block()
    }

    func sync(_ block: () throws -> Void) rethrows {
        lock()
        defer {
            unlock()
        }
        try block()
    }
}
