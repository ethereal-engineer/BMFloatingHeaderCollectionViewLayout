Pod::Spec.new do |s|
  s.name             = "BMFloatingHeaderCollectionViewLayout"
  s.version          = "1.0.0"
  s.summary          = "A UICollectionViewLayout subclass that provides a floating header, detail header, orientation and empty view management"
  s.description      = <<-DESC
                       An optional longer description of BMCollectionViewLayout

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://github.com/iosengineer/BMFloatingHeaderCollectionViewLayout"
  s.license          = 'MIT'
  s.author           = { "Adam Iredale" => "@iosengineer" }
  s.source           = { :git => "http://github.com/iosengineer/BMFloatingHeaderCollectionViewLayout.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/iosengineer'

  s.platform     = :ios, '7.1'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.framework = 'UIKit'
end
