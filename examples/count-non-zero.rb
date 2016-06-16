#!/usr/bin/env ruby

##
##    Calibrate utility for color tracking
##
##    Provides slider and previews to configure/find out HSV ranges values
##    for a given color
##
##    Dumps instances of HSVRange to stdout in yml format (see lib/hsv.rb)
##
##    Key bindings:
##     Enter: add the current range to the collection of ranges
##     Backspace: deletes last added range
##     Escape:  dumps to stdout and exit
##

require "opencv"
require_relative "../lib/hsv"
require 'byebug' if ENV['DEBUG']
require 'yaml'

include OpenCV

class App
  # Key codes
  ESCAPE = 1048603
  ENTER = 1048586
  BACKSPACE = 1113864

  KEY_HANDLERS = {
                  ESCAPE => :exit,
                  BACKSPACE => :delete_range,
                  ENTER => :add_range,
                 }

  def self.run
    new.run
  end

  attr_reader :capture, :ranges, :windows

  def initialize
    @capture = CvCapture::open
    @ranges = YAML.load_file 'config'
    @windows = ranges.map.with_index { |_, i|  GUI::Window.new(i.to_s) }
  end

  def run
    loop do
      image = capture.query
      hsv = image.BGR2HSV
      total_pixels = image.width * image.height

      values = ranges.map.with_index do |range, i|
        img = hsv.in_range(*range.to_cv_scalars).erode(nil, 3).dilate!(nil, 4)
        windows[i].show img
        img.count_non_zero / total_pixels.to_f
      end

      p values

      handle_keyboard_input
    end
  end

  def handle_keyboard_input
    key = GUI::wait_key(1)
    puts "=" * 100, key.inspect,  "=" * 100 if ENV["DEBUG"]
    send KEY_HANDLERS[key] if KEY_HANDLERS[key]
  end
end

App.run
