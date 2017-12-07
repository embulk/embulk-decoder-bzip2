require 'test/unit'

classpath_dir = File.expand_path('../../../../classpath', File.dirname(__FILE__))
jars = Dir.entries(classpath_dir).select {|f| f =~ /\.jar$/ }.sort
jars.each do |jar|
  require File.join(classpath_dir, jar)
end

require 'simplecov'
# fix inaccurate coverage
# see: https://github.com/colszowka/simplecov/blob/82920ca1502be78ccde4fd315634066093bb855d/lib/simplecov.rb#L7
ENV['JRUBY_OPTS'] = '-Xcli.debug=true --debug'
SimpleCov.profiles.define 'embulk' do
  add_filter 'test/'

  add_group 'Libraries', 'lib'
end
SimpleCov.start 'embulk'

require 'embulk/java/bootstrap'
require 'embulk'

require 'embulk/runner'

# "use_global_ruby_runtime" needs to be true because this test process starts from JRuby, the global instance.
runner_java = Embulk::EmbulkRunner.new(Java::org.embulk.EmbulkSetup::setup(
                                         Java::java.util.HashMap.new({"use_global_ruby_runtime": true})))

Embulk.const_set :Runner, runner_java
