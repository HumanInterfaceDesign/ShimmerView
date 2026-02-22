import QuartzCore

enum ShimmerAnimationFactory {

    static let slideKey = "shimmer.slide"
    static let fadeKey = "shimmer.fade"
    static let endFadeKey = "shimmer.fade-end"

    static func slideAnimation(
        duration: CFTimeInterval,
        direction: ShimmerConfiguration.Direction
    ) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "position")
        animation.toValue = NSValue(cgPoint: .zero)
        animation.duration = duration
        animation.repeatCount = .greatestFiniteMagnitude
        if direction == .left || direction == .up {
            animation.speed = -fabsf(animation.speed)
        }
        return animation
    }

    static func fadeAnimation(
        layer: CALayer,
        opacity: CGFloat,
        duration: CFTimeInterval
    ) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = layer.presentation()?.opacity
        animation.toValue = Float(opacity)
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        animation.duration = duration
        return animation
    }

    static func slideRepeat(
        from animation: CAAnimation,
        duration: CFTimeInterval,
        direction: ShimmerConfiguration.Direction
    ) -> CAAnimation {
        let anim = animation.copy() as! CAAnimation
        anim.repeatCount = .greatestFiniteMagnitude
        anim.duration = duration
        anim.speed = (direction == .right || direction == .down)
            ? fabsf(anim.speed)
            : -fabsf(anim.speed)
        return anim
    }

    static func slideFinish(from animation: CAAnimation) -> CAAnimation {
        let anim = animation.copy() as! CAAnimation
        anim.repeatCount = 0
        return anim
    }
}
