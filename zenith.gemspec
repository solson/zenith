Gem::Specification.new do |s|
  s.name        = "zenith"
  s.version     = "0.0.0.pre"
  s.authors     = ["Scott Olson"]
  s.email       = "scott@scott-olson.org"
  s.homepage    = "https://github.com/tsion/zenith"
  s.summary     = %q{An LLVM-compiled stack-based language}
  s.description = s.summary

  s.files       = Dir["lib/**/*.rb", "bin/*", "[A-Z]*"]
  s.executables = Dir["bin/*"].map{|f| File.basename(f) }
end
