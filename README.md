# ShimmerView

A performant UIKit shimmer effect for text loading states. Adapted from the public domain [ShimmerSwift](https://github.com/BeauNouvelle/ShimmerSwift) library with bug fixes, modernized Swift concurrency support, and a cleaner API.

## Installation

Add ShimmerView to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/ShimmerView.git", from: "1.0.0")
]
```

## Usage

Wrap your content in a `ShimmerView` and set `isShimmering = true` to start the animation.

### Basic text shimmer

```swift
import ShimmerView

let shimmer = ShimmerView(frame: CGRect(x: 0, y: 0, width: 280, height: 24))

let label = UILabel()
label.text = "Loading message..."
label.textColor = .white
label.frame = shimmer.bounds
label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
shimmer.contentView.addSubview(label)

// Start shimmering
shimmer.isShimmering = true

// Stop when content loads
shimmer.isShimmering = false
```

### Multiple lines

```swift
func makeLoadingCell(in container: UIView) {
    let lines = [
        CGRect(x: 16, y: 12, width: 240, height: 16),
        CGRect(x: 16, y: 36, width: 200, height: 16),
        CGRect(x: 16, y: 60, width: 160, height: 16),
    ]

    for rect in lines {
        let shimmer = ShimmerView(frame: rect)

        let placeholder = UIView()
        placeholder.backgroundColor = .systemGray4
        placeholder.layer.cornerRadius = 4
        placeholder.frame = shimmer.bounds
        placeholder.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shimmer.contentView.addSubview(placeholder)

        shimmer.isShimmering = true
        container.addSubview(shimmer)
    }
}
```

### Custom configuration

```swift
let shimmer = ShimmerView(frame: frame)

// Set individual properties
shimmer.shimmerSpeed = 300
shimmer.shimmerDirection = .left
shimmer.shimmerAnimationOpacity = 0.3

// Or replace the full configuration
var config = ShimmerConfiguration()
config.speed = 300
config.direction = .left
config.animationOpacity = 0.3
config.pauseDuration = 0.6
shimmer.configuration = config
```

### Configuration options

| Property | Default | Description |
|---|---|---|
| `speed` | `230` | Speed in points per second |
| `direction` | `.right` | Sweep direction (`.right`, `.left`, `.up`, `.down`) |
| `highlightLength` | `1.0` | Highlight band as a fraction of content size [0, 1] |
| `pauseDuration` | `0.4` | Pause between repetitions (seconds) |
| `animationOpacity` | `0.5` | Opacity of the dimmed region |
| `baseOpacity` | `1.0` | Opacity of the bright region |
| `beginFadeDuration` | `0.1` | Fade-in duration when shimmer starts |
| `endFadeDuration` | `0.3` | Fade-out duration when shimmer stops |

## Requirements

- iOS 15+
- Swift 6.0+

## License

Public domain (Unlicense). See [LICENSE](LICENSE) for details.
