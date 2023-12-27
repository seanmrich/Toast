import ComposableArchitecture
import SwiftUI

@main
struct ToastApp: App {
  let store = Store(initialState: Root.State()) {
    Root()._printChanges()
  }
  
  var body: some Scene {
    WindowGroup {
      RootView(store: store)
    }
  }
}
