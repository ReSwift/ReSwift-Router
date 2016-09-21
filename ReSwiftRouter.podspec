Pod::Spec.new do |s|
  s.name             = "ReSwiftRouter"
  s.version          = "0.4.0"
  s.summary          = "Declarative Routing for ReSwift"
  s.description      = <<-DESC
                          A declarative router for ReSwift. Allows developers to declare routes in a similar manner as
                          URLs are used on the web. Using ReSwiftRouter you can navigate your app by defining the target location
                          in the form of a URL-like sequence of identifiers.
                        DESC
  s.homepage         = "https://github.com/ReSwift/ReSwift-Router"
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.author           = { "Benjamin Encz" => "me@benjamin-encz.de" }
  s.social_media_url = "http://twitter.com/benjaminencz"
  s.source           = { :git => "https://github.com/ReSwift/ReSwift-Router.git", :tag => s.version.to_s }
  s.ios.deployment_target     = '8.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc = true
  s.source_files     = 'ReSwiftRouter/**/*.swift'
  s.dependency 'ReSwift', '~> 2.1'
end
