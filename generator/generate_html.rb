#!/usr/bin/ruby
require 'erb'

template = ERB.new(File.read(File.join(__dir__, "template.html.erb")), trim_mode: "%")

%w:index user play:.each do |variant|
  File.open(File.join(__dir__, "..", "webroot", "#{variant}.html"), "w") do |f|
    f.puts template.result(binding)
  end
end