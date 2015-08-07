Pod::Spec.new do |spec|
  spec.name         = 'LibGroupMe'
  spec.version      = '0.0.1'
  spec.license      = 'MIT'
  spec.homepage     = 'https://github.com/jonbalbarin/LibGroupMe'
  spec.authors      = { 'Jon Balbarin' => 'jonbalbarin@gmail.com' }
  spec.summary      = 'a backend library for groupme, in Swift 1.2'
  spec.source_files = "LibGroupMe/*.{swift,m,h}"
  spec.framework    = 'Foundation'
  spec.dependency 'Alamofire', '~> 1.3'
  spec.dependency 'YapDatabase', '~> 2.6'
end
