#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'erb'
require 'nokogiri'

def build_config
  directory_template = File.read(File.join(File.dirname(__FILE__), 'site.conf.erb'))
  template = ERB.new(directory_template)
  puts "Deploying..."
  File.open(ENV['descriptors_config'], 'w') do |f|
    Dir[File.join(ENV['descriptors'], "**" ,"*.vrd")].each do |vrd_file|
      xml = Nokogiri::XML(File.read(vrd_file))
      point = xml.css('point')
      if point
        id = point.attribute('base').value.gsub('/', '')
        dir_path = File.join(ENV['public_dir'], id)
        Dir.mkdir(dir_path) unless Dir.exists?(dir_path)
        f << template.result(binding)
        puts xml.to_s
        puts "Descriptor \"#{id}\" from \"#{vrd_file}\" successfully deployed"
      else
        puts "Invalid descriptor in \"#{vrd_file}\""
      end
    end
  end
  puts "Deploying complete"
end

build_config
