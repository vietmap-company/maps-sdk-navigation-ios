Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name = "VietMapNavigation"
  s.version = "1.0.0"
  s.summary = "Complete turn-by-turn navigation interface for iOS."

  s.description  = <<-DESC
  The VietMap Navigation SDK for iOS is a drop-in interface for turn-by-turn navigation along a route, complete with a well-designed map and easy-to-understand spoken directions. Routes are powered by Mapbox Directions.
                   DESC

  s.homepage = "https://github.com/vietmap-company"
  # s.documentation_url = "https://www.mapbox.com/mapbox-navigation-ios/navigation/"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license = { :type => "ISC", :file => "LICENSE.md" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author = { 'NhatPV' => 'nhatpv@vietmap.vn' }
  # s.social_media_url = "https://twitter.com/mapbox"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = "12.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source = { :git => "https://github.com/nhatpham0301/cocoapod-vietmapnavigation.git", :tag => s.version }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files = ["VietMapNavigation/**/*.{h,m,swift}", "VietMapCoreNavigation/{Date,Sequence,String}.swift"]

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.resources = ['VietMapNavigation/Resources/*/*', 'VietMapNavigation/Resources/*']

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true
  s.module_name = "VietMapNavigation"

  # s.dependency "VietMapCoreNavigation", "#{s.version.to_s}"
  # s.dependency "Mapbox-iOS-SDK", "~> 4.3"
  # s.dependency "Solar", "~> 2.1"
  # s.dependency "MapboxSpeech", "~> 0.0.1"

  # `swift_version` was introduced in CocoaPods 1.4.0. Without this check, if a user were to
  # directly specify this podspec while using <1.4.0, ruby would throw an unknown method error.
  if s.respond_to?(:swift_version)
    s.swift_version = "4.0"
  end

end
