import ComposableArchitecture
import Dependencies
import SwiftUI

@Reducer
struct Root {
  @ObservableState
  struct State {
    @Presents var toast: Toast.State?
  }
  enum Action {
    case showToastButtonTapped
    case task
    case toast(PresentationAction<Toast.Action>)
    case toastObserved(String)
  }
  
  @Dependency(\.toast) var toast
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showToastButtonTapped:
        return .run { _ in
          let id = Int.random(in: 0..<100)
          await toast.present(title: "\(id)")
        }
        
      case .task:
        return .run { send in
          for await title in toast.observe() {
            await send(.toastObserved(title), animation: .easeInOut)
          }
        }
        
      case .toastObserved(let newTitle):
        state.toast = Toast.State(title: newTitle)
        return .none
        
      case .toast:
        return .none
      }
    }
    .ifLet(\.$toast, action: \.toast) {
      Toast()
    }
  }
}

struct RootView: View {
  @Bindable var store: StoreOf<Root>
  
  var body: some View {
    ZStack {
      Color.yellow
        .ignoresSafeArea()
      
      Button("Toast me") {
        store.send(.showToastButtonTapped, animation: .easeInOut)
      }
    }
    .toast(
      store: $store.scope(
        state: \.toast,
        action: \.toast
      )
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
