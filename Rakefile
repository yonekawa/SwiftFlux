def run(command)
  system(command) or raise "RAKE TASK FAILED: #{command}"
end

namespace :test do
  desc "Run unit tests for all iOS targets"
  task :ios do |t|
    run "xcodebuild -project SwiftFlux.xcodeproj -scheme SwiftFlux-iOS -destination 'platform=iOS Simulator,name=iPhone 6' clean test"
  end

  desc "Run unit tests for all OS X targets"
  task :osx do |t|
    run "xcodebuild -project SwiftFlux.xcodeproj -scheme SwiftFlux-Mac clean test"
  end
end
