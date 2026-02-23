# ShimmerView

A performant UIKit shimmer effect for text loading states. Adapted from the public domain [ShimmerSwift](https://github.com/BeauNouvelle/ShimmerSwift) library with bug fixes, modernized Swift concurrency support, and a cleaner API.

## Installation

Add ShimmerView to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/gtokman/ShimmerView.git", from: "1.0.0")
]
```

## Usage

Add a label (or any content) to the `contentView`, then set `isShimmering = true`. The shimmer sweeps across as a translucency mask — your text stays fully readable while a highlight glides through it.

### Text with Auto Layout

```swift
import ShimmerView

let shimmer = ShimmerView()
shimmer.translatesAutoresizingMaskIntoConstraints = false

let label = UILabel()
label.text = "Thinking..."
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
```

### Multiline text

```swift
let shimmer = ShimmerView()
shimmer.translatesAutoresizingMaskIntoConstraints = false

let label = UILabel()
label.text = "Loading message content\nThis might take a moment\nPlease wait"
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

// Stop when content loads
shimmer.isShimmering = false
```

### Custom configuration

```swift
let shimmer = ShimmerView()

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
| `speed` | `600` | Speed in points per second |
| `direction` | `.right` | Sweep direction (`.right`, `.left`, `.up`, `.down`) |
| `highlightLength` | `0.42` | Highlight band as a fraction of content size [0, 1] |
| `pauseDuration` | `0.49` | Pause between repetitions (seconds) |
| `animationOpacity` | `0.57` | Opacity of the dimmed region |
| `baseOpacity` | `1.0` | Opacity of the bright region |
| `beginFadeDuration` | `0.1` | Fade-in duration when shimmer starts |
| `endFadeDuration` | `0.3` | Fade-out duration when shimmer stops |

## Example App

The `Example/` directory contains a demo app with interactive sliders for every configuration property. Generate the Xcode project with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
brew install xcodegen
xcodegen generate
open ShimmerViewExample.xcodeproj
```

## Requirements

- iOS 15+
- Swift 6.0+

## License

Public domain (Unlicense). See [LICENSE](LICENSE) for details.
