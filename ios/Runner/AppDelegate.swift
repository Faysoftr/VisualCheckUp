import AVFoundation
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var alarmAudioPlayer: AVAudioPlayer?

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

    let channel = FlutterMethodChannel(
      name: "com.faysoft.visualcheckup/alarm_audio",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
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
