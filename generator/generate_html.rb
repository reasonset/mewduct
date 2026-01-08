#!/usr/bin/ruby
require 'erb'

template = ERB.new(File.read(File.join(__dir__, "template.html.erb")), trim_mode: "%")

%w:index:.each do |variant|
  puts template.result(binding)
end