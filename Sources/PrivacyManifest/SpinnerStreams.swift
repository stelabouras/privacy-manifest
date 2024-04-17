//
//  SpinnerStreams.swift
//
//
//  Created by Stelios Petrakis on 14/4/24.
//

import Foundation

import Spinner

// Displays several different spinner outputs at once
class ConcurrentSpinnerStream {
    // The array of concurrent silent spinner streams to manage
    var silentSpinnerStreams: [SilentSpinnerStream] = []

    private static let MAX_OUTPUT_LINES = 10

    private var previousRows = 0

    // Serial queue that ensures that console output is serial.
    private let queue = DispatchQueue(label: "stream.queue")
    private let group = DispatchGroup()

    // Serial queue that ensures that there are no race conditions on spinner
    // calls.
    private let spinnersQueue = DispatchQueue(label: "spinner.queue")
    private let spinnersGroup = DispatchGroup()

    init() {
        Self.hideCursor()
    }

    // Renders the added silent spinner streams
    // NOTE: Only call it from within the serial qeueue
    private func render() {
        guard silentSpinnerStreams.count > 0 else {
            return
        }

        // Move cursor at the beginning of the previously rendered string
        if previousRows > 0 {
            print("\u{001B}[\(previousRows)F", terminator: "")
        }
        // Clear from cursor to end of screen
        print("\u{001B}[0J", terminator: "")

        // Generate the buffer
        var buffer = ""
        var linesRendered = 0

        silentSpinnerStreams.sorted().forEach { silentSpinner in
            if linesRendered > Self.MAX_OUTPUT_LINES {
                return
            }
            buffer.append(silentSpinner.buffer + "\n")
            linesRendered += 1
        }

        print("\(buffer)", terminator: "")
        fflush(stdout)

        previousRows = linesRendered
    }

    // Hides the cursor from console
    static func hideCursor() {
        print("\u{001B}[?25l", terminator: "")
        fflush(stdout)
    }

    // Shows the cursor to console
    static func showCursor() {
        print("\u{001B}[?25h", terminator: "")
        fflush(stdout)
    }

    func waitAndShowCursor() {
        // Wait until all async requests have been printed
        _ = spinnersGroup.wait(timeout: .distantFuture)
        _ = group.wait(timeout: .distantFuture)

        Self.showCursor()

        silentSpinnerStreams.removeAll()
        previousRows = 0
    }

    // Adds a silent spinner stream
    func add(stream: SilentSpinnerStream) {
        queue.async(group: group,
                    execute: DispatchWorkItem(block: {
            self.silentSpinnerStreams.append(stream)
        }))
    }

    /// Execute an asynchronous task on the serial queue and optionally render the added silent spinner
    /// streams.
    ///
    /// - Parameters:
    ///   - work: The task to be completed asynchronously within the serial queue
    private func executeSpinnerAsync(work: @escaping () -> Void) {
        spinnersQueue.async(group: spinnersGroup,
                            execute: DispatchWorkItem(block: {
            work()
        }))
    }

    fileprivate func executeSpinnerStreamAsync(work: @escaping () -> Void) {
        queue.async(group: group,
                    execute: DispatchWorkItem(block: {
            work()
            self.render()
        }))
    }

    func start(spinner: Spinner) {
        executeSpinnerAsync {
            spinner.start()
        }
    }

    func success(spinner: Spinner, _ message: String) {
        executeSpinnerAsync {
            spinner.success(message)
        }
    }

    func message(spinner: Spinner, _ message: String) {
        executeSpinnerAsync {
            spinner.message(message)
        }
    }

    func error(spinner: Spinner, _ message: String) {
        executeSpinnerAsync {
            spinner.error(message)
        }
    }

    func createSilentSpinner(with message: String) -> Spinner {
        let silentSpinnerStream = SilentSpinnerStream(concurrentStream: self)
        return Spinner(.dots8Bit, message,
                       stream: silentSpinnerStream)
    }
}

// Writes the spinner stream to a buffer, instead of the stdout
class SilentSpinnerStream: SpinnerStream, Comparable {
    static func == (lhs: SilentSpinnerStream, rhs: SilentSpinnerStream) -> Bool {
        lhs.lastUpdated == rhs.lastUpdated
    }
    
    static func < (lhs: SilentSpinnerStream, rhs: SilentSpinnerStream) -> Bool {
        lhs.lastUpdated > rhs.lastUpdated
    }
    
    var buffer = ""
    var lastUpdated: TimeInterval

    private var concurrentStream: ConcurrentSpinnerStream

    init(concurrentStream: ConcurrentSpinnerStream) {
        self.lastUpdated = Date().timeIntervalSince1970
        self.concurrentStream = concurrentStream
        concurrentStream.add(stream: self)
    }

    func write(string: String, terminator: String) {
        guard string.count > 0 else {
            return
        }
        concurrentStream.executeSpinnerStreamAsync(work: {
            self.lastUpdated = Date().timeIntervalSince1970
            // If the message contains a success or an error character, treat
            // it as the final message for that spinner stream.
            guard !self.buffer.contains("✔") && !self.buffer.contains("✖") else {
                return
            }
            self.buffer = string
        })
    }

    func hideCursor() { }

    func showCursor() { }
}
