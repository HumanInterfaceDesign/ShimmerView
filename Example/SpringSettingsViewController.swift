import UIKit
import ShimmerView

class SpringSettingsViewController: UIViewController {

    // MARK: - Shimmer Controls

    private let speedSlider = UISlider()
    private let highlightSlider = UISlider()
    private let pauseSlider = UISlider()
    private let animOpacitySlider = UISlider()
    private let baseOpacitySlider = UISlider()

    private let speedLabel = UILabel()
    private let highlightLabel = UILabel()
    private let pauseLabel = UILabel()
    private let animOpacityLabel = UILabel()
    private let baseOpacityLabel = UILabel()

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
            snap(600), snap(0.42), snap(0.49), snap(0.57), snap(1.0),
        ]
        setupUI()
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
            min: 50, max: 600, value: 600
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Highlight Length", description: "Highlight band as a fraction of content size [0, 1].",
            slider: highlightSlider, valueLabel: highlightLabel,
            min: 0.0, max: 1.0, value: 0.42
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Pause Duration", description: "Pause between repetitions in seconds.",
            slider: pauseSlider, valueLabel: pauseLabel,
            min: 0.0, max: 2.0, value: 0.49
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Animation Opacity", description: "Opacity of the dimmed region.",
            slider: animOpacitySlider, valueLabel: animOpacityLabel,
            min: 0.0, max: 1.0, value: 0.57
        ))
        contentStack.addArrangedSubview(makeSliderRow(
            title: "Base Opacity", description: "Opacity of the bright region.",
            slider: baseOpacitySlider, valueLabel: baseOpacityLabel,
            min: 0.0, max: 1.0, value: 1.0
        ))

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
        min: Float, max: Float, value: Float
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
        slider.addTarget(self, action: #selector(shimmerChanged), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [headerStack, descLabel, slider])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private func snap(_ v: Float) -> Float { (v / hapticStep).rounded() * hapticStep }

    // MARK: - Shimmer Actions

    @objc private func shimmerChanged() {
        let directions: [ShimmerConfiguration.Direction] = [.right, .left, .up, .down]
        let dir = directions[directionSegment.selectedSegmentIndex]

        let snapped = [
            snap(speedSlider.value), snap(highlightSlider.value), snap(pauseSlider.value),
            snap(animOpacitySlider.value), snap(baseOpacitySlider.value),
        ]
        if snapped != lastHapticValues {
            lastHapticValues = snapped
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

            shimmer.isShimmering = true
        }
    }

    private func updateShimmerLabels() {
        speedLabel.text = String(format: "%.0f", speedSlider.value)
        highlightLabel.text = String(format: "%.2f", highlightSlider.value)
        pauseLabel.text = String(format: "%.2f", pauseSlider.value)
        animOpacityLabel.text = String(format: "%.2f", animOpacitySlider.value)
        baseOpacityLabel.text = String(format: "%.2f", baseOpacitySlider.value)
    }
}
