
Pod::Spec.new do |s|
  s.name         = "CML_SCAN"
  s.version      = "1.0.0"
  s.summary      = "This is a Chanel internal framework that simplifies the implementation of barcode scanner."
  s.homepage     = "https://sources.clasp-infra.com/tfs/DefaultCollection/Mobile/CML/_git/CML_SCAN"
  s.license      = "Chanel"
  s.author             = { "SandhuSukhjeet" => "sukhjeetsingh.s@solcen.in", "NSubramanya" => "subramanya.n@solcen.in" }
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://sources.clasp-infra.com/tfs/DefaultCollection/Mobile/_git/CML_SCAN", :tag => "#{s.version}" }
  s.source_files  = "*.swift"
end
