#!/usr/bin/env ruby

require 'erb'
require 'nokogiri'

def build_config
  directory_template = File.read(File.join(File.dirname(__FILE__), 'site.conf.erb'))
  puts "Deploying..."
template= ERB.new(directory_template)
  File.open(ENV['descriptors_config'], 'w') do |f|
    Dir[File.join(ENV['descriptors'], "**" ,"*.vrd")].each do |vrd_file|
      xml = Nokogiri::XML(File.read(vrd_file))
      id = xml.css('point').attribute('base').value.gsub('/', '')
      dir_path = File.join(ENV['public_dir'], id)
      Dir.mkdir(dir_path) unless Dir.exists?(dir_path)
      f << template.result(binding)
      puts "Descriptor \"#{id}\" from \"#{vrd_file}\" successfully deployed"
    end
  end
  puts "Deploying complete"
end

build_config
