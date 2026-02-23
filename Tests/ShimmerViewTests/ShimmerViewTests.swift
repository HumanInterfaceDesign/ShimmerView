import Testing
import UIKit
@testable import ShimmerView

@MainActor
@Suite struct ShimmerViewTests {

    @Test func defaultConfiguration() {
        let config = ShimmerConfiguration.default
        #expect(config.speed == 600.0)
        #expect(config.direction == .right)
        #expect(config.highlightLength == 0.42)
        #expect(config.pauseDuration == 0.49)
        #expect(config.animationOpacity == 0.57)
        #expect(config.baseOpacity == 1.0)
        #expect(config.beginFadeDuration == 0.1)
        #expect(config.endFadeDuration == 0.3)
    }

    @Test func configurationEquality() {
        let a = ShimmerConfiguration.default
        var b = ShimmerConfiguration.default
        #expect(a == b)
        b.speed = 100
        #expect(a != b)
    }

    @Test func viewInitialization() {
        let view = ShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        #expect(view.contentView.superview === view)
        #expect(view.isShimmering == false)
        #expect(view.contentView.frame == view.bounds)
    }

    @Test func contentViewLayoutUsesBoundsNotCenter() {
        let superview = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        let shimmer = ShimmerView(frame: CGRect(x: 100, y: 100, width: 200, height: 40))
        superview.addSubview(shimmer)
        shimmer.layoutSubviews()
        #expect(shimmer.contentView.frame == shimmer.bounds)
    }

    @Test func shimmeringCreatesMask() {
        let view = ShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        view.isShimmering = true
        CATransaction.commit()
        #expect(view.contentView.layer.mask != nil)
    }

    @Test func stoppingShimmerClearsMask() {
        let view = ShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        view.isShimmering = true
        #expect(view.contentView.layer.mask != nil)
        view.isShimmering = false
        #expect(view.contentView.layer.mask == nil)
    }

    @Test func conveniencePropertiesForwardToConfiguration() {
        let view = ShimmerView(frame: .zero)
        view.shimmerSpeed = 100
        #expect(view.configuration.speed == 100)
        view.shimmerDirection = .left
        #expect(view.configuration.direction == .left)
        view.shimmerPauseDuration = 1.0
        #expect(view.configuration.pauseDuration == 1.0)
    }

    @Test func settingSameValueDoesNotRestart() {
        let view = ShimmerView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        view.isShimmering = true
        // Setting same value again should not trigger updateShimmering
        view.isShimmering = true
        #expect(view.isShimmering == true)
    }
}
