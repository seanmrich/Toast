public struct ToastState: Sendable {
  public var title: String
  public var icon: String
  
  public init(title: String, icon: String) {
    self.title = title
    self.icon = icon
  }
}
