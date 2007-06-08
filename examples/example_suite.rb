class ExampleSuite
  def run
    dir = File.dirname(__FILE__)
    Dir["#{dir}/**/*_example.rb"].each do |file|
      require file
    end
  end
end

if $0 == __FILE__
  ExampleSuite.new.run
end
