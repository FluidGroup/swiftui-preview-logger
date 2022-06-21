import SwiftUI
import os.log

public struct Log {

  public static let `default`: Log = {
    .init(subsystem: "Default", category: "")
  }()

  public let osLog: OSLog
  public let subsystem: String
  public let category: String

  public init(subsystem: String, category: String) {

    self.subsystem = subsystem
    self.category = category
    self.osLog = OSLog(subsystem: subsystem, category: category)
  }

}

public enum PreviewLog {

  @inline(__always)
  private static func send(_ logObject: Log = .default, _ type: OSLogType, _ message: String) {
    os_log(type, log: logObject.osLog, "%{public}@", message)
    LogStorage.shared.send(
      Record.init(
        subsystem: logObject.subsystem,
        category: logObject.category,
        type: type,
        body: message
      )
    )
  }

  public static func debug(_ logObject: Log, _ message: String) {
    send(logObject, .debug, message)
  }

  public static func error(_ logObject: Log, _ message: String) {
    send(logObject, .error, message)
  }

}

struct Record: Identifiable {
  var id: UUID = .init()
  var date: Date = .init()

  var subsystem: String
  var category: String

  var type: OSLogType
  var body: String
}

final class LogStorage: ObservableObject {

  private let lock = NSLock()

  static let shared = LogStorage()

  @Published private(set) var logs: [Record] = []

  func send(_ record: Record) {
    lock.lock()
    defer {
      lock.unlock()
    }
    logs.append(record)
  }

  func clear() {
    lock.lock()
    defer {
      lock.unlock()
    }
    logs = []
  }
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
    VStack {
      HStack {
        Spacer()
        Button {
          storage.clear()
        } label: {
          Image(systemName: "trash")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            
        }
      }
      .padding(.horizontal)
      ScrollView {
        VStack {
          ForEach(storage.logs.reversed()) { log in
            
            HStack {
              
              circle(type: log.type)
              
              Text(Static.formatter.string(from: log.date))
                .font(.system(size: 9))
              
              Text(log.subsystem)
                .font(.system(size: 9))
              
              Text(log.category)
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
