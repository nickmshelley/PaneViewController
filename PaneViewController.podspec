Pod::Spec.new do |s|
  s.name         = "PaneViewController"
  s.version      = "1.4.0"
  s.summary      = "A side drawer controller"
  s.homepage     = "https://www.lds.org/pages/mobileapps?lang=eng"
  s.description  = <<-DESC
A side drawer controller that toggles between modal and side by side view depending on horizontal trait collection
                   DESC
  s.license      = { :type => 'Commercial', :text => "Copyright (c) 2016 Intellectual Reserve, Inc. All rights reserved." }
  s.author       = { "Branden Russell" => "brandenr@rain.agency" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/LDSChurch/PaneViewController.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = "PaneViewController/*.{h,m,swift}"
  s.framework    = "UIKit"
  s.dependency "Swiftification"
end
