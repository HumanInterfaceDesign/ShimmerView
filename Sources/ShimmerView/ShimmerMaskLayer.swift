import UIKit

final class ShimmerMaskLayer: CAGradientLayer {

    let fadeLayer = CALayer()

    override init() {
        super.init()
        fadeLayer.backgroundColor = UIColor.white.cgColor
        addSublayer(fadeLayer)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        fadeLayer.frame = bounds
    }
}
