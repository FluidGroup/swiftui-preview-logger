import SwiftUI
import os.log

public enum PreviewLog {
  
  public static func debug(_ objects: Any...) {
    let string = objects.map { "\($0)" }.joined(separator: ", ")
    LogStorage.shared.logs.append(Log.init(type: .debug, body: string))
  }
   
  public static func error(_ objects: Any...) {
    let string = objects.map { "\($0)" }.joined(separator: ", ")
    LogStorage.shared.logs.append(Log.init(type: .error, body: string))
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
              .foregroundColor(.black.opacity(0.8))
            Text("\(log.body)")
              .font(.system(size: 9))
              .foregroundColor(.black)
            
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
