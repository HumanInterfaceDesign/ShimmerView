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
            updateShimmering()
        }
    }

    /// The shimmer configuration. Changing any property restarts the animation.
    public var configuration: ShimmerConfiguration = .default {
        didSet {
            guard oldValue != configuration else { return }
            updateShimmering()
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

    private var maskLayer: ShimmerMaskLayer?
    private var shimmerBeginTime: CFTimeInterval = .greatestFiniteMagnitude
    private var shimmerFadeTime: CFTimeInterval?

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
        if maskLayer != nil {
            updateMaskLayout()
        }
    }

    // MARK: - Shimmer orchestration

    private func updateShimmering() {
        createMaskIfNeeded()

        guard let maskLayer else {
            return
        }

        let isShimmering = self.isShimmering
        let config = self.configuration

        let contentLayer = contentView.layer
        let maskBounds = contentLayer.bounds
        let isHorizontal = (config.direction == .right || config.direction == .left)
        let contentLength = isHorizontal ? maskBounds.width : maskBounds.height

        guard contentLength > 0 else { return }

        layoutIfNeeded()

        if isShimmering {
            // Cancel any pending end fade so its completion doesn't clear the mask
            maskLayer.fadeLayer.removeAnimation(forKey: ShimmerAnimationFactory.endFadeKey)

            // Start shimmer
            contentLayer.mask = maskLayer

            let duration = CFTimeInterval(contentLength / config.speed) + config.pauseDuration
            let animation = ShimmerAnimationFactory.slideAnimation(
                duration: duration,
                direction: config.direction
            )

            animation.fillMode = .forwards
            animation.isRemovedOnCompletion = false

            shimmerBeginTime = CACurrentMediaTime() + config.beginFadeDuration
            animation.beginTime = shimmerBeginTime

            maskLayer.add(animation, forKey: ShimmerAnimationFactory.slideKey)

            updateMaskColors()
            updateMaskLayout()

            // Fade in
            let fade = ShimmerAnimationFactory.fadeAnimation(
                layer: maskLayer.fadeLayer,
                opacity: 0.0,
                duration: config.beginFadeDuration
            )
            maskLayer.fadeLayer.add(fade, forKey: ShimmerAnimationFactory.fadeKey)
            shimmerFadeTime = CFAbsoluteTimeGetCurrent()
        } else {
            // Only stop if shimmer is actually running
            let hasSlideAnimation = maskLayer.animation(forKey: ShimmerAnimationFactory.slideKey) != nil
            guard hasSlideAnimation else { return }

            // Remove slide animation immediately so subsequent config
            // changes don't re-enter the stop branch
            maskLayer.removeAnimation(forKey: ShimmerAnimationFactory.slideKey)

            // Stop shimmer
            let endFadeDuration = config.endFadeDuration

            let now = CFAbsoluteTimeGetCurrent()
            let minOpacity: CGFloat
            if let fadeTime = shimmerFadeTime {
                let elapsed = now - fadeTime
                minOpacity = max(0, CGFloat(elapsed / max(0.001, config.beginFadeDuration)))
            } else {
                minOpacity = 1.0
            }

            shimmerFadeTime = nil
            shimmerBeginTime = .greatestFiniteMagnitude

            let actualEndFadeDuration = CFTimeInterval(min(1.0, minOpacity)) * endFadeDuration

            let fade = ShimmerAnimationFactory.fadeAnimation(
                layer: maskLayer.fadeLayer,
                opacity: 1.0,
                duration: actualEndFadeDuration
            )
            fade.delegate = self
            maskLayer.fadeLayer.add(fade, forKey: ShimmerAnimationFactory.endFadeKey)
        }
    }

    private func createMaskIfNeeded() {
        guard isShimmering, maskLayer == nil else { return }
        let mask = ShimmerMaskLayer()
        maskLayer = mask
        contentView.layer.mask = mask
    }

    private func clearMask() {
        if let mask = maskLayer {
            mask.removeAllAnimations()
            mask.fadeLayer.removeAllAnimations()
            contentView.layer.mask = nil
        }
        maskLayer = nil
    }

    private func updateMaskColors() {
        guard let maskLayer else { return }

        let config = configuration
        let maskedColor = UIColor(white: 1.0, alpha: config.baseOpacity)
        let unmaskedColor = UIColor(white: 1.0, alpha: config.animationOpacity)

        maskLayer.colors = [
            unmaskedColor.cgColor,
            maskedColor.cgColor,
            unmaskedColor.cgColor,
        ]
    }

    private func updateMaskLayout() {
        guard let maskLayer else { return }

        let config = configuration
        let contentLayer = contentView.layer
        let contentBounds = contentLayer.bounds

        let isHorizontal = (config.direction == .right || config.direction == .left)
        let contentLength = isHorizontal ? contentBounds.width : contentBounds.height

        guard contentLength > 0 else { return }

        let highlightLength = contentLength * config.highlightLength
        let extraDistance = contentLength + config.speed * CGFloat(config.pauseDuration)
        let fullShimmerLength = highlightLength * 3.0 + extraDistance
        let travelDistance = highlightLength * 2.0 + extraDistance

        let highlightOutsideLength = (1.0 - config.highlightLength) / 2.0
        let startLocation = NSNumber(value: Float(highlightOutsideLength))
        let endLocation = NSNumber(value: Float(1.0 - highlightOutsideLength))
        maskLayer.locations = [startLocation, NSNumber(value: 0.5), endLocation]

        let maskWidth = isHorizontal ? fullShimmerLength : contentBounds.width
        let maskHeight = isHorizontal ? contentBounds.height : fullShimmerLength

        maskLayer.bounds = CGRect(x: 0, y: 0, width: maskWidth, height: maskHeight)
        maskLayer.position = CGPoint(x: contentBounds.midX, y: contentBounds.midY)

        let startX: CGFloat = isHorizontal ? 0 : 0.5
        let startY: CGFloat = isHorizontal ? 0.5 : 0
        let endX: CGFloat = isHorizontal ? 1 : 0.5
        let endY: CGFloat = isHorizontal ? 0.5 : 1

        maskLayer.startPoint = CGPoint(x: startX - 0.0001, y: startY - 0.0001)
        maskLayer.endPoint = CGPoint(x: endX + 0.0001, y: endY + 0.0001)

        let offset: CGFloat = isHorizontal ? -travelDistance : 0
        let offsetY: CGFloat = isHorizontal ? 0 : -travelDistance
        maskLayer.anchorPoint = .zero
        maskLayer.position = CGPoint(x: offset, y: offsetY)

        if let slide = maskLayer.animation(forKey: ShimmerAnimationFactory.slideKey) {
            let duration = CFTimeInterval(travelDistance / config.speed) + config.pauseDuration
            let repeated = ShimmerAnimationFactory.slideRepeat(
                from: slide,
                duration: duration,
                direction: config.direction
            )
            maskLayer.add(repeated, forKey: ShimmerAnimationFactory.slideKey)
        }
    }
}

// MARK: - CAAnimationDelegate

extension ShimmerView: CAAnimationDelegate {

    nonisolated public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return }
        MainActor.assumeIsolated {
            clearMask()
        }
    }
}
