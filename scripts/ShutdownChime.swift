import Cocoa
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var playback: Process?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(willPowerOff),
            name: NSWorkspace.willPowerOffNotification,
            object: nil
        )
    }

    @objc private func willPowerOff(_ note: Notification) {
        playIfNeeded()
    }

    private func playIfNeeded() {
        guard playback == nil else { return }
        let task = Process()
        task.launchPath = "/usr/bin/afplay"
        task.arguments = ["-v", "1.2", "/Users/Shared/chime/chime-15s.mp3"]
        do {
            try task.run()
            playback = task
        } catch {
            playback = nil
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        let reason = NSAppleEventManager.shared()
            .currentAppleEvent?
            .attributeDescriptor(forKeyword: AEKeyword(kAEQuitReason))
        let code = reason?.enumCodeValue ?? 0
        let shutdownCodes: [OSType] = [
            kAELogOut, kAEReallyLogOut,
            kAERestart, kAEShowRestartDialog,
            kAEShutDown, kAEShowShutdownDialog
        ]
        if shutdownCodes.contains(code) {
            playIfNeeded()
            if let task = playback, task.isRunning {
                DispatchQueue.global(qos: .background).async {
                    task.waitUntilExit()
                    DispatchQueue.main.async {
                        NSApp.reply(toApplicationShouldTerminate: true)
                    }
                }
                return .terminateLater
            }
        }
        return .terminateNow
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
