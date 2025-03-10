Scalar.setup do |config|
  puts "Scalar setup"
  config.specification = File.read(Rails.root.join("docs/openapi.yml"))
  config.scalar_configuration = { theme: "elysiajs" }
end
