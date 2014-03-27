#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "BMFloatingHeaderCollectionViewLayout"
  s.version          = "0.1.0"
  s.summary          = "A UICollectionViewLayout subclass that provides a floating header, detail header, orientation and empty view management"
  s.description      = <<-DESC
                       An optional longer description of BMCollectionViewLayout

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://EXAMPLE/NAME"
  s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Adam Iredale" => "@iosengineer" }
  s.source           = { :git => "http://EXAMPLE/NAME.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/iosengineer'

  s.platform     = :ios, '7.1'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.framework = 'UIKit'
end
