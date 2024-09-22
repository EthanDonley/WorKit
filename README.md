# WorKit

**WorKit** is an AI-Powered Fitness app that is intended to improve your form and give you optimal workout recommendations based on personal background. 

## Prerequisites
- Xcode (latest version recommended)
- CocoaPods
- A Firebase project with authentication enabled

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/EthanDonley/WorKit.git
cd WorKit
```

### 2. Install dependencies
This project uses **CocoaPods** for dependency management. After cloning the repository, install the required dependencies:

`pod install`

Make sure you're using the **.xcworkspace** file to open the project after installing pods:
 
`open WorKit.xcworkspace`

## 3. Firebase Setup

### 1. Access Firebase:
If you don't already have access, ask for permissions to be added to the Firebase project.

#### Firebase Website: https://firebase.google.com/?hl=en&authuser=0

### 2. Download GoogleService-Info.plist:

- Go to the Firebase Console
- Download the GoogleService-Info.plist file for the iOS app from Project Settings > General > Your apps.

### 3. Add the GoogleService-Info.plist File:
- Place the GoogleService-Info.plist file in the root of the WorKit folder (Next to Podfile).

## Contributing

### Please ensure all contributions align with the project structure and follow common GitHub etiquette:

1. Fork the repository.
2. Create a new branch `git checkout -b feature/your-feature-name`.
3. Commit your changes `git commit -m "Added new feature"`.
4. Push to the branch `git push origin feature/your-feature-name`.
5. Open a pull request.

## License

This project is licensed under the MIT License.
