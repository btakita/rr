
module RR
  VERSION = File.read(File.expand_path('../../../VERSION', __FILE__)).strip
  def self.version; VERSION; end
end
