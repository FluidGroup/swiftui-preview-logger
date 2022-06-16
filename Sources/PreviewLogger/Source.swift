import SwiftUI

public enum Log {
  
  static func debug(_ objects: Any...) {
    let string = objects.map { "\($0)" }.joined(separator: ", ")
    LogStorage.shared.logs.append("\n")
    LogStorage.shared.logs.append(string)
  }
}

final class LogStorage: ObservableObject {
  static let shared = LogStorage()
  
  @Published var logs: String = ""
}

public struct LogView: View {
  
  @ObservedObject var storage = LogStorage.shared
  
  public init() {
    
  }
  
  public var body: some View {
    ScrollView {
      TextField("", text: $storage.logs)
        .disabled(true)
        .font(.system(size: 9))
    }
  }
}
