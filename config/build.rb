#!/usr/bin/env ruby

require 'erb'

def build_config
  directory_template = File.read(File.join(File.dirname(__FILE__), 'site.conf.erb'))
  File.open(ENV['descriptors_config'], 'w') do |f|
    Dir[File.join(ENV['descriptors'], "*.vrd")].each do |vrd_file|
      id = File.basename(vrd_file, '.vrd')
      dir_path = File.join(ENV['public_dir'], id)
      Dir.mkdir(dir_path) unless Dir.exists?(dir_path)

      @site = {
        id: id,
        dir: dir_path,
        vrd: vrd_file
      }
      f << ERB.new(directory_template).result
    end
  end
end

build_config
