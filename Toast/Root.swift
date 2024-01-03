import ComposableArchitecture
import Dependencies
import SwiftUI

@Reducer
struct Root {
  @ObservableState
  struct State {
    var toast: ToastState?
  }
  enum Action {
    case showToastButtonTapped
    case task
    case toast(Toast)
    
    enum Toast {
      case timerFinished
      case toastObserved(ToastState)
    }
  }
  
  @Dependency(\.continuousClock) var clock
  @Dependency(\.toast) var toast
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      enum CancelID { case timer }
      
      switch action {
      case .showToastButtonTapped:
        return .run { _ in
          let next = [ToastState.copy, .paste, .undo].randomElement()!
          await toast.present(toast: next)
        }
        
      case .task:
        return .run { send in
          for await toastState in toast.observe() {
            await send(.toast(.toastObserved(toastState)), animation: .bouncy)
          }
        }
        
      case .toast(.timerFinished):
        state.toast = nil
        return .none
        
      case .toast(.toastObserved(let new)):
        state.toast = new
        return .run { send in
          try await clock.sleep(for: .seconds(1))
          await send(.toast(.timerFinished), animation: .easeIn(duration: 0.15))
        }
        .cancellable(id: CancelID.timer, cancelInFlight: true)
      }
    }
  }
}

struct RootView: View {
  @Bindable var store: StoreOf<Root>
  
  var body: some View {
    NavigationStack {
      ZStack {
        Color.yellow
          .ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 0) {
            Color.red.frame(height: 100)
            Color.purple.frame(height: 100)
            Color.orange.frame(height: 100)
            Color.pink.frame(height: 100)
            Color.red.frame(height: 100)
            Color.purple.frame(height: 100)
            Color.orange.frame(height: 100)
            Color.pink.frame(height: 100)
            Button("Toast me") {
              store.send(.showToastButtonTapped)
            }
            .padding(.top)
          }
        }
      }
      .navigationTitle("Toasty")
    }
    .toast(
      toast: store.toast
    )
    .task {
      await store.send(.task).finish()
    }
  }
}


#Preview("Root") {
  RootView(
    store: Store(initialState: Root.State()) {
      Root()
    }
  )
}


private extension ToastState {
  static var copy: Self {
    ToastState(
      title: "Copied",
      icon: "doc.on.doc"
    )
  }
  
  static var paste: Self {
    ToastState(
      title: "Pasted",
      icon: "doc.on.clipboard"
    )
  }
  
  static var undo: Self {
    ToastState(
      title: "Undo",
      icon: "arrow.uturn.left"
    )
  }
}
