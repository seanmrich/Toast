import AsyncAlgorithms
import ComposableArchitecture
import Dependencies

@DependencyClient
struct ToastClient: Sendable {
  var observe: @Sendable () -> AsyncStream<ToastState> = { AsyncStream([ToastState]().async) }
  var present: @Sendable (_ toast: ToastState) async -> Void
}

extension ToastClient: TestDependencyKey {
  static let testValue = ToastClient()
}

extension ToastClient: DependencyKey {
  static let liveValue = {
    let (stream, continuation) = AsyncStream.makeStream(of: ToastState.self)
    return ToastClient(
      observe: { stream },
      present: { continuation.yield($0) }
    )
  }()
}

extension DependencyValues {
  var toast: ToastClient {
    get { self[ToastClient.self] }
    set { self[ToastClient.self] = newValue }
  }
}
