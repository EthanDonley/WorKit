platform :ios, '13.0'

target 'WorKit' do
  use_frameworks!
  
  # Firebase Authentication
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'FirebaseRemoteConfig'
  pod 'FirebaseAnalytics' 

end

post_install do |installer|
  # Find and replace double-quoted imports with angle-bracketed ones for Recaptcha-related headers
  Dir.glob('Pods/RecaptchaInterop/**/*.h').each do |header|
    text = File.read(header)
    new_text = text.gsub(/#import "([^"]+)"/, '#import <\1>')
    File.open(header, "w") { |file| file.puts new_text }
  end
end