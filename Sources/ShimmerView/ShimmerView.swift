import UIKit

@MainActor
public final class ShimmerView: UIView {

    // MARK: - Public API

    /// Add your content (labels, images, etc.) to this view.
    public let contentView = UIView()

    /// Set to `true` to start the shimmer animation.
    public var isShimmering: Bool = false {
        didSet {
            guard oldValue != isShimmering else { return }
            if isShimmering {
                startShimmer()
            } else {
                stopShimmer()
            }
        }
    }

    /// The shimmer configuration. Changing any property restarts the animation.
    public var configuration: ShimmerConfiguration = .default {
        didSet {
            guard oldValue != configuration else { return }
            if isShimmering {
                startShimmer()
            }
        }
    }

    // MARK: - Convenience computed properties

    public var shimmerSpeed: CGFloat {
        get { configuration.speed }
        set { configuration.speed = newValue }
    }

    public var shimmerDirection: ShimmerConfiguration.Direction {
        get { configuration.direction }
        set { configuration.direction = newValue }
    }

    public var shimmerHighlightLength: CGFloat {
        get { configuration.highlightLength }
        set { configuration.highlightLength = newValue }
    }

    public var shimmerPauseDuration: CFTimeInterval {
        get { configuration.pauseDuration }
        set { configuration.pauseDuration = newValue }
    }

    public var shimmerAnimationOpacity: CGFloat {
        get { configuration.animationOpacity }
        set { configuration.animationOpacity = newValue }
    }

    public var shimmerOpacity: CGFloat {
        get { configuration.baseOpacity }
        set { configuration.baseOpacity = newValue }
    }

    public var shimmerBeginFadeDuration: CFTimeInterval {
        get { configuration.beginFadeDuration }
        set { configuration.beginFadeDuration = newValue }
    }

    public var shimmerEndFadeDuration: CFTimeInterval {
        get { configuration.endFadeDuration }
        set { configuration.endFadeDuration = newValue }
    }

    // MARK: - Private state

    private var shimmerLayer: CAGradientLayer?
    private var lastContentSize: CGSize = .zero

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        if isShimmering {
            let newSize = contentView.bounds.size
            if shimmerLayer == nil || newSize != lastContentSize {
                lastContentSize = newSize
                startShimmer()
            }
        }
    }

    // MARK: - Shimmer

    private func startShimmer() {
        stopShimmer()
        layoutIfNeeded()

        let config = configuration
        let contentBounds = contentView.bounds
        let isHorizontal = config.direction == .right || config.direction == .left
        let contentLength = isHorizontal ? contentBounds.width : contentBounds.height

        guard contentLength > 0 else { return }

        let gradient = CAGradientLayer()

        // Feathered bell-curve highlight: dim edges ease in slowly,
        // ramp through the middle, then ease back out.
        let a0 = config.animationOpacity
        let a1 = config.baseOpacity
        let range = a1 - a0

        func c(_ alpha: CGFloat) -> CGColor {
            UIColor(white: 1, alpha: alpha).cgColor
        }

        gradient.colors = [
            c(a0),
            c(a0 + range * 0.08),
            c(a0 + range * 0.35),
            c(a1),
            c(a0 + range * 0.35),
            c(a0 + range * 0.08),
            c(a0),
        ]

        let outside = (1.0 - config.highlightLength) / 2.0
        let band = config.highlightLength
        gradient.locations = [
            NSNumber(value: Float(outside)),
            NSNumber(value: Float(outside + band * 0.18)),
            NSNumber(value: Float(outside + band * 0.35)),
            NSNumber(value: 0.5),
            NSNumber(value: Float(1.0 - outside - band * 0.35)),
            NSNumber(value: Float(1.0 - outside - band * 0.18)),
            NSNumber(value: Float(1.0 - outside)),
        ]

        // Gradient direction
        if isHorizontal {
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        } else {
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        }

        // The gradient must always cover the content with dim areas while
        // the highlight slides through.
        // Layout: [dim pad ≥ contentLength | highlight | dim pad ≥ contentLength]
        let highlightSize = contentLength * config.highlightLength
        let totalLength = contentLength * 2 + highlightSize

        let width = isHorizontal ? totalLength : contentBounds.width
        let height = isHorizontal ? contentBounds.height : totalLength
        gradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
        gradient.anchorPoint = .zero

        // Position so the highlight starts just off-screen
        let forward = config.direction == .right || config.direction == .down
        let offset = -(contentLength + highlightSize)
        if isHorizontal {
            gradient.position = CGPoint(x: forward ? offset : 0, y: 0)
        } else {
            gradient.position = CGPoint(x: 0, y: forward ? offset : 0)
        }

        contentView.layer.mask = gradient
        shimmerLayer = gradient
        lastContentSize = contentBounds.size

        // Additive slide animation (inspired by Telegram's shimmer)
        let travelDistance = contentLength + highlightSize
        let keyPath = isHorizontal ? "position.x" : "position.y"

        let anim = CABasicAnimation(keyPath: keyPath)
        anim.isAdditive = true
        anim.fromValue = 0
        anim.toValue = forward ? travelDistance : -travelDistance
        anim.duration = CFTimeInterval(travelDistance / config.speed) + config.pauseDuration
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .linear)

        // Sync animation across multiple ShimmerViews
        anim.beginTime = 1.0

        gradient.add(anim, forKey: "shimmer")
    }

    private func stopShimmer() {
        shimmerLayer?.removeAllAnimations()
        contentView.layer.mask = nil
        shimmerLayer = nil
    }
}
