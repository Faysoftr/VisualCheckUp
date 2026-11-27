import AVFoundation
import CoreMotion
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, FlutterStreamHandler {
  private var alarmAudioPlayer: AVAudioPlayer?
  private let pedometer = CMPedometer()
  private var stepEventSink: FlutterEventSink?
  private var lastReportedSteps: Int = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()

    let channel = FlutterMethodChannel(
      name: "com.faysoft.visualcheckup/alarm_audio",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(false)
        return
      }
      switch call.method {
      case "play":
        let args = call.arguments as? [String: Any]
        let soundKey = (args?["soundKey"] as? String) ?? "alarm_classic"
        let loop = (args?["loop"] as? Bool) ?? false
        result(self.playAlarmSound(soundKey: soundKey, loop: loop))
      case "stop":
        self.stopAlarmSound()
        result(true)
      case "getSystemAlarmUri":
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let stepChannel = FlutterEventChannel(
      name: "com.faysoft.visualcheckup/step_events",
      binaryMessenger: messenger
    )
    stepChannel.setStreamHandler(self)
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    stepEventSink = events
    lastReportedSteps = 0
    if CMPedometer.isStepCountingAvailable() {
      let startDate = Date()
      pedometer.startUpdates(from: startDate) { [weak self] data, error in
        guard let self = self, error == nil, let total = data?.numberOfSteps.intValue else {
          return
        }
        let delta = total - self.lastReportedSteps
        if delta > 0 {
          self.lastReportedSteps = total
          DispatchQueue.main.async {
            self.stepEventSink?(["delta": delta])
          }
        }
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    pedometer.stopUpdates()
    stepEventSink = nil
    lastReportedSteps = 0
    return nil
  }

  private func playAlarmSound(soundKey: String, loop: Bool) -> Bool {
    stopAlarmSound()
    let resourceName = (soundKey == "system_alarm") ? "alarm_classic" : soundKey
    guard
      let url = Bundle.main.url(forResource: resourceName, withExtension: "wav")
        ?? Bundle.main.url(forResource: "alarm_classic", withExtension: "wav")
    else {
      return false
    }

    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [.duckOthers])
      try session.setActive(true)

      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = loop ? -1 : 0
      player.volume = 1.0
      player.prepareToPlay()
      player.play()
      alarmAudioPlayer = player
      return true
    } catch {
      stopAlarmSound()
      return false
    }
  }

  private func stopAlarmSound() {
    alarmAudioPlayer?.stop()
    alarmAudioPlayer = nil
    try? AVAudioSession.sharedInstance().setActive(
      false,
      options: [.notifyOthersOnDeactivation]
    )
  }
}
