platform :ios, '15.0'

target 'WorKit' do
  use_frameworks!

  # Firebase services with specific versions compatible with ML Kit
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'FirebaseRemoteConfig'
  pod 'FirebaseAnalytics'

  # Google ML Kit for Pose Detection
  pod 'GoogleMLKit/PoseDetection'
  pod 'GoogleMLKit/PoseDetectionAccurate'

end

post_install do |installer|
  # Find and replace double-quoted imports with angle-bracketed ones for Recaptcha-related headers
  Dir.glob('Pods/RecaptchaInterop/**/*.h').each do |header|
    text = File.read(header)
    new_text = text.gsub(/#import "([^"]+)"/, '#import <\1>')
    File.open(header, "w") { |file| file.puts new_text }
  end
end
