import ComposableArchitecture
import Dependencies
import SwiftUI

@Reducer
struct Toast {
  @ObservableState
  struct State {
    var title: String
    
    init(title: String) {
      self.title = title
    }
  }
  enum Action: Sendable {
    case task
    case timerFinished
  }
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.dismiss) var dismiss
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      
      switch action {
      case .task:
        return .run { [clock] send in
          try await clock.sleep(for: .seconds(1))
          await send(.timerFinished)
        }
        
      case .timerFinished:
        return .run { [dismiss] _ in
          await dismiss(animation: .easeInOut)
        }
      }
    }
  }
}


struct ToastView: View {
  let store: StoreOf<Toast>
  
  var body: some View {
    Text(store.title)
      .font(.caption)
      .task {
        store.send(.task)
      }
  }
}

struct ToastModifier: ViewModifier {
  @Binding var store: StoreOf<Toast>?
  
  func body(content: Content) -> some View {
    content
      .overlay(alignment: .top) {
        if let store {
          ToastView(store: store)
        }
      }
  }
}

extension View {
  func toast(
    store: Binding<Store<Toast.State, Toast.Action>?>
  ) -> some View {
    self
      .modifier(ToastModifier(store: store))
  }
}
