import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var didRegisterAudioTools = false

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    registerAudioToolsIfPossible()
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    registerAudioToolsIfPossible()
  }

  private func registerAudioToolsIfPossible() {
    guard !didRegisterAudioTools,
          let controller = window?.rootViewController as? FlutterViewController
    else {
      return
    }
    AudioToolsPlugin.register(with: controller.binaryMessenger)
    didRegisterAudioTools = true
  }
}
