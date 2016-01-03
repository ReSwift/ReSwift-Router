Pod::Spec.new do |s|
  s.name             = "SwiftFlowRouter"
  s.version          = "0.2.1"
  s.summary          = "Declarative Routing for Swift Flow"
  s.description      = <<-DESC
                          A declarative router for Swift Flow. Allows developers to declare routes in a similar manner as
                          URLs are used on the web. Using Swift Flow Router you can navigate your app by defining the target location
                          in the form of a URL-like sequence of identifiers.
                        DESC
  s.homepage         = "https://github.com/Swift-Flow/Swift-Flow-Router"
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.author           = { "Benjamin Encz" => "me@benjamin-encz.de" }
  s.social_media_url = "http://twitter.com/benjaminencz"
  s.source           = { :git => "https://github.com/Swift-Flow/Swift-Flow-Router.git", :tag => "v#{s.version.to_s}" }
  s.ios.deployment_target     = '8.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc = true
  s.source_files     = 'SwiftFlowRouter/**/*.swift'
  s.dependency 'SwiftFlow', '~> 0.2'
end
