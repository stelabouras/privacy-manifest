//
//  SpinnerStreams.swift
//
//
//  Created by Stelios Petrakis on 14/4/24.
//

import Foundation

import Spinner

// Display several different spinner outputs concurrently
class ConcurrentSpinnerStream {
    // The array of concurrent silent spinner streams to manage
    var silentSpinners: [SilentSpinnerStream] = []

    private var previousRows = 0
    private let queue = DispatchQueue(label: "concurrent.spinner.stream")
    private let group = DispatchGroup()

    init() {
        // Hides the cursor from console
        print("\u{001B}[?25l", terminator: "")
        fflush(stdout)
    }

    // Renders the added silent spinner streams
    // NOTE: Only call it from within the serial qeueue
    private func render() {
        guard silentSpinners.count > 0 else {
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
        silentSpinners.forEach { silentSpinner in
            buffer.append(silentSpinner.buffer + "\n")
        }
        print("\(buffer)", terminator: "")
        fflush(stdout)
        previousRows = silentSpinners.count
    }

    func waitAndShowCursor() {
        // Wait until all async requests have been printed
        _ = group.wait(timeout: .distantFuture)
        // Shows the cursor to console
        print("\u{001B}[?25h", terminator: "")
        fflush(stdout)
    }

    // Adds a silent spinner stream
    func add(stream: SilentSpinnerStream) {
        queue.async(group: group,
                    execute: DispatchWorkItem(block: {
            self.silentSpinners.append(stream)
        }))
    }

    /// Execute an asynchronous task on the serial queue and optionally render the added silent spinner
    /// streams.
    ///
    /// - Parameters:
    ///   - work: The task to be completed asynchronously within the serial queue
    ///   - render: Whether after the asynchronous execution of the task, the added silent spinner
    ///   streams should be rendered or not.
    fileprivate func executeAsync(work: @escaping () -> Void,
                      render: Bool = false) {
        queue.async(group: group,
                    execute: DispatchWorkItem(block: {
            work()
            if render {
                self.render()
            }
        }))
    }

    func start(spinner: Spinner) {
        executeAsync {
            spinner.start()
        }
    }

    func success(spinner: Spinner, _ message: String) {
        executeAsync {
            spinner.success(message)
        }
    }

    func message(spinner: Spinner, _ message: String) {
        executeAsync {
            spinner.message(message)
        }
    }

    func error(spinner: Spinner, _ message: String) {
        executeAsync {
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
class SilentSpinnerStream: SpinnerStream {
    var buffer = ""

    private var concurrentStream: ConcurrentSpinnerStream

    init(concurrentStream: ConcurrentSpinnerStream) {
        self.concurrentStream = concurrentStream
        concurrentStream.add(stream: self)
    }

    func write(string: String, terminator: String) {
        guard string.count > 0 else {
            return
        }
        concurrentStream.executeAsync(work: {
            // If the message contains a success or an error character, treat
            // it as the final message for that spinner stream.
            guard !self.buffer.contains("✔") && !self.buffer.contains("✖") else {
                return
            }
            self.buffer = string
        }, render: true)
    }

    func hideCursor() { }

    func showCursor() { }
}
