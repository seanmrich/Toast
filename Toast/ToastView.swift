import ComposableArchitecture
import Dependencies
import SwiftUI

//@Reducer
//struct Toast {
//  @ObservableState
//  struct State {
//    var title: String
//  }
//  enum Action: Sendable {
//    case task
//    case timerFinished
//  }
//  
//  @Dependency(\.continuousClock) var clock
//  @Dependency(\.dismiss) var dismiss
//  
//  var body: some ReducerOf<Self> {
//    Reduce { state, action in
//      
//      switch action {
//      case .task:
//        return .run { [clock] send in
//          try await clock.sleep(for: .seconds(1))
//          await send(.timerFinished)
//        }
//        
//      case .timerFinished:
//        return .run { [dismiss] _ in
//          await dismiss(animation: .easeInOut)
//        }
//      }
//    }
//  }
//}


struct ToastView: View {
  let toast: ToastState
  @ScaledMetric var verticalPadding = 8.0
  @ScaledMetric var horizontalPadding = 14.0
  @ScaledMetric var horizontalRadius = 16.0
  @ScaledMetric var verticalRadius = 12.0
  
  var body: some View {
    Label(toast.title, systemImage: toast.icon)
      .font(.caption)
      .padding(.horizontal, horizontalPadding)
      .padding(.vertical, verticalPadding)
      .background(.regularMaterial)
      .clipShape(
        RoundedRectangle(
          cornerSize: CGSize(width: horizontalRadius, height: verticalRadius)
        )
      )
      .shadow(radius: 5)
      .transition(
        .asymmetric(
          insertion: .opacity.combined(with: .offset(x: 20)),
          removal: .opacity.combined(with: .offset(x: -20))
        )
      )
  }
}


struct ToastModifier: ViewModifier {
//  @Binding var store: StoreOf<Toast>?
  let toast: ToastState?
  
  func body(content: Content) -> some View {
    content
      .overlay(alignment: .top) {
        if let toast {
          ToastView(toast: toast)
        }
//        if let store {
//          ToastView(store: store)
//        }
      }
  }
}

extension View {
  func toast(
//    store: Binding<Store<Toast.State, Toast.Action>?>
    toast: ToastState?
  ) -> some View {
    self
      .modifier(ToastModifier(toast: toast))
//      .modifier(ToastModifier(store: store))
  }
}

#Preview {
  ToastView(
    toast: ToastState(title: "Copied", icon: "doc.on.doc")
  )
}
