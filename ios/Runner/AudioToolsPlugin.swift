import AVFoundation
import Flutter
import UIKit

final class AudioToolsPlugin {
  private static var channel: FlutterMethodChannel?

  static func register(with messenger: FlutterBinaryMessenger) {
    let audioToolsChannel = FlutterMethodChannel(
      name: "haze_bot_app/audio_tools",
      binaryMessenger: messenger
    )
    audioToolsChannel.setMethodCallHandler { call, result in
      guard call.method == "convertToPcmWav" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard
        let args = call.arguments as? [String: String],
        let inputPath = args["inputPath"],
        let outputPath = args["outputPath"]
      else {
        result(FlutterError(
          code: "bad_args",
          message: "Expected inputPath and outputPath",
          details: nil
        ))
        return
      }
      do {
        try convertToPcmWav(inputPath: inputPath, outputPath: outputPath)
        result(1)
      } catch {
        result(FlutterError(
          code: "convert_failed",
          message: error.localizedDescription,
          details: nil
        ))
      }
    }
    channel = audioToolsChannel
    NSLog("Haze audio tools channel registered")
  }

  private static func convertToPcmWav(inputPath: String, outputPath: String) throws {
    let inputUrl = URL(fileURLWithPath: inputPath)
    let outputUrl = URL(fileURLWithPath: outputPath)
    let inputFile = try AVAudioFile(forReading: inputUrl)
    let inputFormat = inputFile.processingFormat
    guard inputFormat.channelCount > 0 else {
      throw AudioConversionError.invalidFormat
    }
    guard
      let floatFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: inputFormat.sampleRate,
        channels: inputFormat.channelCount,
        interleaved: false
      )
    else {
      throw AudioConversionError.invalidFormat
    }
    guard
      let buffer = AVAudioPCMBuffer(
        pcmFormat: floatFormat,
        frameCapacity: AVAudioFrameCount(inputFile.length)
      )
    else {
      throw AudioConversionError.invalidBuffer
    }
    try inputFile.read(into: buffer)
    guard let channelData = buffer.floatChannelData else {
      throw AudioConversionError.invalidBuffer
    }

    let channels = Int(buffer.format.channelCount)
    let frameCount = Int(buffer.frameLength)
    let sampleRate = Int(buffer.format.sampleRate.rounded())
    var pcm = Data(capacity: frameCount * channels * 2)
    for frame in 0..<frameCount {
      for channel in 0..<channels {
        let sample = max(-1.0, min(1.0, channelData[channel][frame]))
        let scaled = sample < 0 ? sample * 32768.0 : sample * 32767.0
        var intSample = Int16(scaled.rounded()).littleEndian
        Swift.withUnsafeBytes(of: &intSample) { pcm.append(contentsOf: $0) }
      }
    }
    let wav = wavData(pcm: pcm, sampleRate: sampleRate, channels: channels)
    try FileManager.default.createDirectory(
      at: outputUrl.deletingLastPathComponent(),
      withIntermediateDirectories: true
    )
    try wav.write(to: outputUrl, options: .atomic)
  }

  private static func wavData(pcm: Data, sampleRate: Int, channels: Int) -> Data {
    let bitsPerSample = 16
    let byteRate = sampleRate * channels * bitsPerSample / 8
    let blockAlign = channels * bitsPerSample / 8
    var data = Data()
    data.append("RIFF".data(using: .ascii)!)
    data.appendUInt32LE(UInt32(36 + pcm.count))
    data.append("WAVE".data(using: .ascii)!)
    data.append("fmt ".data(using: .ascii)!)
    data.appendUInt32LE(16)
    data.appendUInt16LE(1)
    data.appendUInt16LE(UInt16(channels))
    data.appendUInt32LE(UInt32(sampleRate))
    data.appendUInt32LE(UInt32(byteRate))
    data.appendUInt16LE(UInt16(blockAlign))
    data.appendUInt16LE(UInt16(bitsPerSample))
    data.append("data".data(using: .ascii)!)
    data.appendUInt32LE(UInt32(pcm.count))
    data.append(pcm)
    return data
  }
}

private enum AudioConversionError: LocalizedError {
  case invalidFormat
  case invalidBuffer

  var errorDescription: String? {
    switch self {
    case .invalidFormat:
      return "Unsupported audio format"
    case .invalidBuffer:
      return "Could not read audio buffer"
    }
  }
}

private extension Data {
  mutating func appendUInt16LE(_ value: UInt16) {
    var littleEndian = value.littleEndian
    Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
  }

  mutating func appendUInt32LE(_ value: UInt32) {
    var littleEndian = value.littleEndian
    Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
  }
}
