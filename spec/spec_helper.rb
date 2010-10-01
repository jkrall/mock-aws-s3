$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'mock-aws-s3'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|

end
