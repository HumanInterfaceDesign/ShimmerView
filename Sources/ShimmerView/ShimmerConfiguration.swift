import Foundation

public struct ShimmerConfiguration: Sendable, Equatable {

    public enum Direction: Sendable {
        case right, left, up, down
    }

    /// Speed in points per second.
    public var speed: CGFloat = 600.0

    /// The direction of the shimmer sweep.
    public var direction: Direction = .right

    /// Highlight band length as a fraction of the content size [0, 1].
    public var highlightLength: CGFloat = 0.42

    /// Pause between shimmer repetitions in seconds.
    public var pauseDuration: CFTimeInterval = 0.49

    /// Opacity of the content in the "dimmed" part of the sweep.
    public var animationOpacity: CGFloat = 0.57

    /// Opacity of the content in the "bright" part of the sweep.
    public var baseOpacity: CGFloat = 1.0

    /// Duration of the fade-in when shimmer starts.
    public var beginFadeDuration: CFTimeInterval = 0.1

    /// Duration of the fade-out when shimmer stops.
    public var endFadeDuration: CFTimeInterval = 0.3

    public static let `default` = ShimmerConfiguration()

    public init() {}
}
