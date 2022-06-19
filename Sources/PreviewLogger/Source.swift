import SwiftUI
import os.log

public enum PreviewLog {

  @inline(__always)
  private static func send(_ logObject: OSLog = .default, _ type: OSLogType, _ message: String) {
    os_log(type, log: logObject, "%{public}@", message)
    LogStorage.shared.logs.append(Log.init(type: .error, body: message))
  }
  
  public static func debug(_ logObject: OSLog, _ message: String) {
    send(logObject, .debug, message)
  }
  
  public static func error(_ logObject: OSLog, _ message: String) {
    send(logObject, .error, message)
  }
      
}

struct Log: Identifiable {
  var id: UUID = .init()
  var date: Date = .init()
  
  var type: OSLogType
  var body: String
}

final class LogStorage: ObservableObject {
  static let shared = LogStorage()
  
  @Published var logs: [Log] = []
}

private enum Static {

  // To support iOS 13
  static let formatter: DateFormatter = {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss.SSSSSS"
    
    return dateFormatter
  }()
  
}

public struct LogView: View {
  
  @ObservedObject var storage = LogStorage.shared
  
  public init() {
    
  }
  
  public var body: some View {
    ScrollView {
      VStack {
        ForEach(storage.logs.reversed()) { log in
          
          HStack {
            
            circle(type: log.type)
            
            Text(Static.formatter.string(from: log.date))
              .font(.system(size: 9))
            Text("\(log.body)")
              .font(.system(size: 9))
            
            Spacer()
            
          }
          .padding(.vertical, 2)
          .padding(.horizontal)
        }
      }
    }

  }
  
  @ViewBuilder
  private func circle(type: OSLogType) -> some View {
    switch type {
    case .debug:
      circle(color: .gray)
    case .error:
      circle(color: .red)
    default:
      circle(color: .yellow)
    }
  }
  
  private func circle(color: Color) -> some View {
    Circle()
      .foregroundColor(color)
      .frame(width: 6, height: 6)
  }
}
