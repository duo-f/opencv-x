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
require_relative "lib/hsv"
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

  attr_reader :capture, :range, :ranges, :windows

  def initialize
    @capture = CvCapture::open
    @range = HSVRange.new HSV.new(22, 139, 67), HSV.new(89, 255, 265) # verde (el de la carpeta)
    @ranges = []

    window = GUI::Window.new("0")
    window.move(650, 0)
    window.set_trackbar("H from", 255, range.from.h) { |value| range.from.h = value }
    window.set_trackbar("H to  ", 255, range.to.h)   { |value| range.to.h   = value }
    window.set_trackbar("S from", 255, range.from.s) { |value| range.from.s = value }
    window.set_trackbar("S to  ", 255, range.to.s)   { |value| range.to.s   = value }
    window.set_trackbar("V from", 255, range.from.v) { |value| range.from.v = value }
    window.set_trackbar("V to  ", 255, range.to.v)   { |value| range.to.v   = value }

    @windows = {
                raw: GUI::Window.new("Raw"),
                hsv: GUI::Window.new("HSV"),
                filter_by_range: GUI::Window.new("Filter by range"),
                noise_reduction: GUI::Window.new("Noise Reduction")
               }

    windows[:raw].move(0,0)
    windows[:hsv].move(980,0)
    windows[:filter_by_range].move(0,600)
    windows[:noise_reduction].move(980,600)
  end

  def add_range
    ranges << range
    @range = HSVRange.new(range.from.clone, range.to.clone)
  end

  def delete_range
    @range = ranges.shift unless ranges.empty?
  end

  def exit
    puts YAML.dump ranges
    super
  end

  def run
    loop do
      image = capture.query
      windows[:raw].show image

      hsv = image.BGR2HSV
      windows[:hsv].show hsv

      filter_by_range = hsv.in_range(*range.to_cv_scalars)
      windows[:filter_by_range].show filter_by_range

      noise_reduction = filter_by_range.erode(nil, 3).dilate!(nil, 5)
      windows[:noise_reduction].show noise_reduction

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
