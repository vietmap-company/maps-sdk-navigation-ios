Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name = "VietMapCoreNavigation"
  s.version = "2.1.5"
  s.summary           = 'Vietmap Navigation'
  s.homepage          = 'https://github.com/vietmap-company'
  s.documentation_url = "https://maps.vietmap.vn/docs/sdk-mobile/sdk-ios/sdk-ios-ver2.0/"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license = { :type => "ISC", :text => "LICENSE.md" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author            = { 'NhatPV' => 'nhatpv@vietmap.vn' }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = "12.0"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source = { 
  :git => "https://github.com/vietmap-company/maps-sdk-navigation-ios.git", 
  :tag => s.version.to_s }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # s.source_files = "VietMapCoreNavigation"

  # # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # s.requires_arc = true
  # s.module_name = "VietMapCoreNavigation"

  # s.dependency "VietMapDirections.swift", "~> 2.0.1"
  # # s.dependency "MapboxMobileEvents", "~> 0.5"
  # s.dependency "VietMapTurf", "~> 1.0.2"

  s.source_files = ["RouteTest/Fixture.swift", "VietMapCoreNavigation"]

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  # s.resources = ['RouteTest/*']

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true
  s.module_name = "VietMapCoreNavigation"

  s.dependency "VietMapDirections.swift", "~> 2.0.1"
  # s.dependency "MapboxMobileEvents", "~> 0.5"
  s.dependency "VietMapTurf", "~> 1.0.2"

  # `swift_version` was introduced in CocoaPods 1.4.0. Without this check, if a user were to
  # directly specify this podspec while using <1.4.0, ruby would throw an unknown method error.
  if s.respond_to?(:swift_version)
    s.swift_version = "5.0"
  end
end
