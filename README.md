# SwiftUI Short Video Feed 📱

A modern iOS app built with SwiftUI that creates a TikTok/Instagram Reels-style short video feed experience with smooth scrolling and automatic video playback.


## 🚀 Features

- **Vertical Video Feed**: Full-screen vertical video scrolling experience
- **iOS Version Compatibility**: Automatically adapts UI based on iOS version
  - iOS 17+: Modern ScrollView with `.scrollTargetBehavior(.paging)`
  - iOS 16 and below: TabView-based implementation with rotation effects
- **Auto Video Playback**: Videos automatically play when they come into view
- **Smooth Transitions**: Seamless video switching with optimized player management
- **Modern SwiftUI**: Built entirely with SwiftUI and AVKit
- **Clean Architecture**: Reusable components with MVVM pattern



## 📋 Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## 🔧 Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/swiftui-video-feed.git
```

2. Open the project in Xcode:
```bash
cd swiftui-video-feed
open ShortsApp.xcodeproj
```

3. Build and run the project on your device or simulator



## 🎯 Key Features Explained

### Automatic iOS Version Detection
The app automatically detects the iOS version and uses the appropriate implementation:
- **iOS 17+**: Uses the new ScrollView APIs for better performance
- **iOS 16 and below**: Falls back to TabView with custom rotation effects

### Video Player Management
- Centralized video player logic through `VideoPlayerHelper`
- Automatic video loading and playback
- Memory-efficient video switching
- Handles player state management across different views

### Responsive Design
- Adapts to different screen sizes
- Full-screen video experience
- Smooth animations and transitions

## 🔄 Usage

Replace the mock data in `ShortsViewModel` with your actual video URLs:

```swift
self.posts = [
    Post(
        id: UUID().uuidString,
        videoUrl: "your-video-url",
        thumbnailUrl: "your-thumbnail-url",
        caption: "Your caption",
        username: "username",
        userProfilePictureUrl: "profile-pic-url",
        likeCount: 0,
        commentCount: 0
    )
]
```

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Rezaul Islam Tarek**
- Portfolio: [rezaulislamtarek.github.io](https://rezaulislamtarek.github.io/portfolio/)

## 🙏 Acknowledgments

- Inspired by TikTok and Instagram Reels
- Built with modern SwiftUI best practices
- Thanks to the iOS development community

---

⭐ **Star this repository if you found it helpful!**
