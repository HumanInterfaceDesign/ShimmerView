import UIKit
import ShimmerView

protocol SpringSettingsDelegate: AnyObject {
    func springSettingsDidChange(duration: CGFloat, damping: CGFloat, initialVelocity: CGFloat)
}

class SpringSettingsViewController: UIViewController {

    weak var delegate: SpringSettingsDelegate?

    var currentDuration: CGFloat = 1.0
    var currentDamping: CGFloat = 0.78
    var currentVelocity: CGFloat = 0.1

    // MARK: - Spring Controls

    private let durationSlider = UISlider()
    private let dampingSlider = UISlider()
    private let velocitySlider = UISlider()

    private let durationLabel = UILabel()
    private let dampingLabel = UILabel()
    private let velocityLabel = UILabel()

    private let curveView = SpringCurveView()
    private let demoView = SpringDemoView()

    // MARK: - Shimmer Controls

    private let speedSlider = UISlider()
    private let highlightSlider = UISlider()
    private let pauseSlider = UISlider()
    private let animOpacitySlider = UISlider()
    private let baseOpacitySlider = UISlider()
    private let beginFadeSlider = UISlider()
    private let endFadeSlider = UISlider()

    private let speedLabel = UILabel()
    private let highlightLabel = UILabel()
    private let pauseLabel = UILabel()
    private let animOpacityLabel = UILabel()
    private let baseOpacityLabel = UILabel()
    private let beginFadeLabel = UILabel()
    private let endFadeLabel = UILabel()

    private let directionSegment = UISegmentedControl(items: ["Right", "Left", "Up", "Down"])

    private var shimmerViews: [ShimmerView] = []

    // MARK: - Haptics

    private let selectionFeedback = UISelectionFeedbackGenerator()
    private var lastHapticValues: [Float] = []
    private let hapticStep: Float = 0.05

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        selectionFeedback.prepare()
        lastHapticValues = [
            snap(Float(currentDuration)), snap(Float(currentDamping)), snap(Float(currentVelocity)),
            snap(230), snap(1.0), snap(0.4), snap(0.5), snap(1.0), snap(0.1), snap(0.3),
        ]
        setupUI()
        curveView.update(damping: currentDamping, velocity: currentVelocity)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        demoView.animate(duration: currentDuration, damping: currentDamping, velocity: currentVelocity)
    }

    // MARK: - UI Setup

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
        ])

        // --- Spring Section ---
        contentStack.addArrangedSubview(makeSectionTitle("Spring Animation"))

        curveView.translatesAutoresizingMaskIntoConstraints = false
        curveView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        contentStack.addArrangedSubview(curveView)

        demoView.translatesAutoresizingMaskIntoConstraints = false
        demoView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        contentStack.addArrangedSubview(demoView)

        contentStack.addArrangedSubview(makeSliderRow(
            title: "Duration", description: "Total time in seconds. Longer = slower, more gradual motion.",
            slider: durationSlider, valueLabel: durationLabel,
            min: 0.1, max: 3.0, value: Float(currentDuration), tag: 0
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Damping", description: "How quickly the spring settles. 1.0 = no bounce. Lower = more oscillation.",
            slider: dampingSlider, valueLabel: dampingLabel,
            min: 0.1, max: 1.0, value: Float(currentDamping), tag: 0
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Initial Velocity", description: "Starting speed. 0 = starts from rest. Higher = stronger initial push.",
            slider: velocitySlider, valueLabel: velocityLabel,
            min: 0.0, max: 2.0, value: Float(currentVelocity), tag: 0
        ))

        // --- Divider ---
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.2, alpha: 1)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(divider)

        // --- Shimmer Section ---
        contentStack.addArrangedSubview(makeSectionTitle("Shimmer"))

        // Demo shimmer views
        let demoTexts = [
            "Thinking...",
            "Generating a response for your question about Swift programming",
            "Loading message content\nThis might take a moment\nPlease wait",
        ]

        let demoContainer = UIStackView()
        demoContainer.axis = .vertical
        demoContainer.spacing = 12
        for text in demoTexts {
            let shimmer = ShimmerView()
            shimmer.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.font = .systemFont(ofSize: 16)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            shimmer.contentView.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: shimmer.contentView.topAnchor),
                label.leadingAnchor.constraint(equalTo: shimmer.contentView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: shimmer.contentView.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: shimmer.contentView.bottomAnchor),
            ])

            shimmer.isShimmering = true
            shimmerViews.append(shimmer)
            demoContainer.addArrangedSubview(shimmer)
        }
        contentStack.addArrangedSubview(demoContainer)

        // Direction
        directionSegment.selectedSegmentIndex = 0
        directionSegment.addTarget(self, action: #selector(shimmerChanged), for: .valueChanged)
        let dirRow = makeLabeledRow(title: "Direction", control: directionSegment)
        contentStack.addArrangedSubview(dirRow)

        // Shimmer sliders
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Speed", description: "Speed in points per second.",
            slider: speedSlider, valueLabel: speedLabel,
            min: 50, max: 600, value: 230, tag: 1
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Highlight Length", description: "Highlight band as a fraction of content size [0, 1].",
            slider: highlightSlider, valueLabel: highlightLabel,
            min: 0.0, max: 1.0, value: 1.0, tag: 1
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Pause Duration", description: "Pause between repetitions in seconds.",
            slider: pauseSlider, valueLabel: pauseLabel,
            min: 0.0, max: 2.0, value: 0.4, tag: 1
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Animation Opacity", description: "Opacity of the dimmed region.",
            slider: animOpacitySlider, valueLabel: animOpacityLabel,
            min: 0.0, max: 1.0, value: 0.5, tag: 1
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Base Opacity", description: "Opacity of the bright region.",
            slider: baseOpacitySlider, valueLabel: baseOpacityLabel,
            min: 0.0, max: 1.0, value: 1.0, tag: 1
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Begin Fade Duration", description: "Fade-in duration when shimmer starts.",
            slider: beginFadeSlider, valueLabel: beginFadeLabel,
            min: 0.0, max: 1.0, value: 0.1, tag: 1
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "End Fade Duration", description: "Fade-out duration when shimmer stops.",
            slider: endFadeSlider, valueLabel: endFadeLabel,
            min: 0.0, max: 1.0, value: 0.3, tag: 1
        ))

        updateLabels()
        updateShimmerLabels()
    }

    // MARK: - Helpers

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }

    private func makeLabeledRow(title: String, control: UIView) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(white: 0.6, alpha: 1)

        let stack = UIStackView(arrangedSubviews: [titleLabel, control])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func makeSliderRow(
        title: String, description: String,
        slider: UISlider, valueLabel: UILabel,
        min: Float, max: Float, value: Float, tag: Int
    ) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(white: 0.6, alpha: 1)

        valueLabel.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        valueLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        headerStack.axis = .horizontal

        let descLabel = UILabel()
        descLabel.text = description
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = UIColor(white: 0.45, alpha: 1)
        descLabel.numberOfLines = 0

        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.tintColor = .white
        slider.tag = tag

        if tag == 0 {
            slider.addTarget(self, action: #selector(springSliderChanged), for: .valueChanged)
            slider.addTarget(self, action: #selector(springSliderReleased), for: [.touchUpInside, .touchUpOutside])
        } else {
            slider.addTarget(self, action: #selector(shimmerChanged), for: .valueChanged)
        }

        let stack = UIStackView(arrangedSubviews: [headerStack, descLabel, slider])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func snap(_ v: Float) -> Float { (v / hapticStep).rounded() * hapticStep }

    // MARK: - Spring Actions

    @objc private func springSliderChanged() {
        currentDuration = CGFloat(durationSlider.value)
        currentDamping = CGFloat(dampingSlider.value)
        currentVelocity = CGFloat(velocitySlider.value)
        updateLabels()
        curveView.update(damping: currentDamping, velocity: currentVelocity)

        let snapped = [snap(durationSlider.value), snap(dampingSlider.value), snap(velocitySlider.value)]
        if snapped != Array(lastHapticValues.prefix(3)) {
            lastHapticValues.replaceSubrange(0..<3, with: snapped)
            selectionFeedback.selectionChanged()
        }

        delegate?.springSettingsDidChange(
            duration: currentDuration, damping: currentDamping, initialVelocity: currentVelocity
        )
    }

    private var demoWorkItem: DispatchWorkItem?

    @objc private func springSliderReleased() {
        demoWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.demoView.animate(duration: self.currentDuration, damping: self.currentDamping, velocity: self.currentVelocity)
        }
        demoWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33, execute: item)
    }

    private func updateLabels() {
        durationLabel.text = String(format: "%.2f", currentDuration)
        dampingLabel.text = String(format: "%.2f", currentDamping)
        velocityLabel.text = String(format: "%.2f", currentVelocity)
    }

    // MARK: - Shimmer Actions

    @objc private func shimmerChanged() {
        let directions: [ShimmerConfiguration.Direction] = [.right, .left, .up, .down]
        let dir = directions[directionSegment.selectedSegmentIndex]

        let snapped = [
            snap(speedSlider.value), snap(highlightSlider.value), snap(pauseSlider.value),
            snap(animOpacitySlider.value), snap(baseOpacitySlider.value),
            snap(beginFadeSlider.value), snap(endFadeSlider.value),
        ]
        if snapped != Array(lastHapticValues.suffix(7)) {
            lastHapticValues.replaceSubrange(3..<10, with: snapped)
            selectionFeedback.selectionChanged()
        }

        updateShimmerLabels()

        for shimmer in shimmerViews {
            shimmer.isShimmering = false

            shimmer.shimmerSpeed = CGFloat(speedSlider.value)
            shimmer.shimmerDirection = dir
            shimmer.shimmerHighlightLength = CGFloat(highlightSlider.value)
            shimmer.shimmerPauseDuration = CFTimeInterval(pauseSlider.value)
            shimmer.shimmerAnimationOpacity = CGFloat(animOpacitySlider.value)
            shimmer.shimmerOpacity = CGFloat(baseOpacitySlider.value)
            shimmer.shimmerBeginFadeDuration = CFTimeInterval(beginFadeSlider.value)
            shimmer.shimmerEndFadeDuration = CFTimeInterval(endFadeSlider.value)

            shimmer.isShimmering = true
        }
    }

    private func updateShimmerLabels() {
        speedLabel.text = String(format: "%.0f", speedSlider.value)
        highlightLabel.text = String(format: "%.2f", highlightSlider.value)
        pauseLabel.text = String(format: "%.2f", pauseSlider.value)
        animOpacityLabel.text = String(format: "%.2f", animOpacitySlider.value)
        baseOpacityLabel.text = String(format: "%.2f", baseOpacitySlider.value)
        beginFadeLabel.text = String(format: "%.2f", beginFadeSlider.value)
        endFadeLabel.text = String(format: "%.2f", endFadeSlider.value)
    }
}

// MARK: - Spring Math

private func springPosition(t: CGFloat, damping: CGFloat, velocity: CGFloat) -> CGFloat {
    let omega: CGFloat = 4 * .pi
    let zeta = damping

    if zeta >= 1.0 {
        let expTerm = exp(-zeta * omega * t)
        return 1 - expTerm * (1 + (omega * zeta - velocity) * t)
    } else {
        let omegaD = omega * sqrt(1 - zeta * zeta)
        let expTerm = exp(-zeta * omega * t)
        let cosComp = cos(omegaD * t)
        let sinComp = sin(omegaD * t)
        let sinCoeff = (zeta * omega - velocity) / omegaD
        return 1 - expTerm * (cosComp + sinCoeff * sinComp)
    }
}

// MARK: - Curve View

private class SpringCurveView: UIView {

    private var damping: CGFloat = 0.78
    private var velocity: CGFloat = 0.1

    private let curveLayer = CAShapeLayer()
    private let gridLayer = CAShapeLayer()
    private let targetLine = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.06, alpha: 1)
        layer.cornerRadius = 10
        clipsToBounds = true

        gridLayer.strokeColor = UIColor(white: 0.2, alpha: 1).cgColor
        gridLayer.lineWidth = 0.5
        gridLayer.fillColor = nil
        layer.addSublayer(gridLayer)

        targetLine.strokeColor = UIColor(white: 0.3, alpha: 1).cgColor
        targetLine.lineWidth = 1
        targetLine.lineDashPattern = [4, 4]
        targetLine.fillColor = nil
        layer.addSublayer(targetLine)

        curveLayer.strokeColor = UIColor.white.cgColor
        curveLayer.lineWidth = 2
        curveLayer.fillColor = nil
        curveLayer.lineCap = .round
        curveLayer.lineJoin = .round
        layer.addSublayer(curveLayer)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(damping: CGFloat, velocity: CGFloat) {
        self.damping = damping
        self.velocity = velocity
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawCurve()
    }

    private func drawCurve() {
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        let inset: CGFloat = 12
        let plotW = w - inset * 2
        let plotH = h - inset * 2

        let gridPath = UIBezierPath()
        let y0 = inset + plotH
        gridPath.move(to: CGPoint(x: inset, y: y0))
        gridPath.addLine(to: CGPoint(x: w - inset, y: y0))
        let yHalf = inset + plotH * 0.5
        gridPath.move(to: CGPoint(x: inset, y: yHalf))
        gridPath.addLine(to: CGPoint(x: w - inset, y: yHalf))
        gridLayer.path = gridPath.cgPath

        let targetPath = UIBezierPath()
        targetPath.move(to: CGPoint(x: inset, y: inset))
        targetPath.addLine(to: CGPoint(x: w - inset, y: inset))
        targetLine.path = targetPath.cgPath

        let steps = Int(plotW)
        let path = UIBezierPath()
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let value = springPosition(t: t, damping: damping, velocity: velocity)
            let minVal: CGFloat = -0.1
            let maxVal: CGFloat = 1.3
            let normalized = (value - minVal) / (maxVal - minVal)
            let x = inset + t * plotW
            let y = inset + plotH * (1 - normalized)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        curveLayer.path = path.cgPath
    }
}

// MARK: - Demo View

private class SpringDemoView: UIView {

    private let ball: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        return v
    }()

    private let trackLayer = CAShapeLayer()
    private var ballLeading: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.06, alpha: 1)
        layer.cornerRadius = 10
        clipsToBounds = true

        trackLayer.strokeColor = UIColor(white: 0.2, alpha: 1).cgColor
        trackLayer.lineWidth = 1
        trackLayer.fillColor = nil
        trackLayer.lineDashPattern = [2, 4]
        layer.addSublayer(trackLayer)

        ball.translatesAutoresizingMaskIntoConstraints = false
        addSubview(ball)
        ballLeading = ball.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        NSLayoutConstraint.activate([
            ball.centerYAnchor.constraint(equalTo: centerYAnchor),
            ball.widthAnchor.constraint(equalToConstant: 24),
            ball.heightAnchor.constraint(equalToConstant: 24),
            ballLeading,
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let y = bounds.midY
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 12, y: y))
        path.addLine(to: CGPoint(x: bounds.width - 12, y: y))
        trackLayer.path = path.cgPath
    }

    func animate(duration: CGFloat, damping: CGFloat, velocity: CGFloat) {
        let endX = bounds.width - 12 - 24
        guard endX > 12 else { return }
        ball.layer.removeAllAnimations()
        ballLeading.constant = 12
        layoutIfNeeded()
        ballLeading.constant = endX
        UIView.animate(
            withDuration: duration, delay: 0,
            usingSpringWithDamping: damping, initialSpringVelocity: velocity,
            options: [.allowUserInteraction]
        ) { self.layoutIfNeeded() }
    }
}
