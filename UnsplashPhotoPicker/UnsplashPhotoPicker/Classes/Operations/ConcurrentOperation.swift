//
//  ConcurrentOperation.swift
//
//  Created by Francois Courville on 2016-12-27.
//  Copyright © 2016 FrankCourville.com. All rights reserved.
//

import Foundation

open class ConcurrentOperation: Operation {

    public var error: Error?

    public override init() {
        overrideExecuting = false
        overrideFinished = false

        super.init()
    }

    public override func start() {
        isExecuting = true

        if isCancelled || hasCancelledDependency() {
            cancel()
            completeOperation()
            return
        }

        main()
    }

    public func completeOperation() {
        isExecuting = false
        isFinished = true
    }

    public final func completeWithError(_ error: Error) {
        self.error = error
        cancelAndCompleteOperation()
    }

    public func cancelAndCompleteOperation() {
        cancel()
        completeOperation()
    }

    private var overrideExecuting: Bool
    public override var isExecuting: Bool {
        get { return overrideExecuting }
        set {
            willChangeValue(forKey: "isExecuting")
            overrideExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var overrideFinished: Bool
    public override var isFinished: Bool {
        get { return overrideFinished }
        set {
            willChangeValue(forKey: "isFinished")
            overrideFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

}

extension Operation {
    func hasCancelledDependency() -> Bool {
        for operation in dependencies where operation.isCancelled { return true }
        return false
    }
}
