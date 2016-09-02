@version = "0.0.3"

Pod::Spec.new do |s|
  s.name                  = "View2ViewTransition"
  s.version               = @version
  s.summary               = "Provide custom interactive viewController transition from one view to another view."
  s.homepage              = "https://github.com/naru-jpn/View2ViewTransition"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { "naru" => "tus.naru@gmail.com" }
  s.source                = { :git => "https://github.com/naru-jpn/View2ViewTransition.git", :tag => @version }
  s.source_files          = 'Sources/*.swift'
  s.ios.deployment_target = '9.0'
end
