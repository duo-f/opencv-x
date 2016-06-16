#!/usr/bin/env ruby
require "opencv"
require_relative "lib/hsv"
require 'byebug' if ENV['DEBUG']
require 'yaml'

include OpenCV

class App
  ESCAPE_KEY = 1048603

  def self.run(config = nil)
    config ||= "./config"
    new(config).run
  end

  attr_reader :capture, :ranges, :steps, :windows

  def initialize(config_file)
    @ranges = YAML.load_file config_file
    @steps = 8
    @capture = CvCapture::open
    width = capture.query.width / steps
    @windows = 0.upto(steps - 1).map do |step|
      ranges.map.with_index do |_, color|
        GUI::Window.new("#{step} - #{color}").tap do |w|
          x = step * ranges.size * width + color * width
          w.move x, 0
        end
      end
    end
  end

  def run
    image = capture.query
    total_pixels = (image.width / steps) * image.height

    loop do
      image = capture.query.BGR2HSV

      sequence = 0.upto(steps - 1).map do |step|
        roi = region_for_step(step)
        [].tap do |values|
          image.set_roi(roi) do |img|
            ranges.map.with_index do |range, i|
              img = img.in_range(*range.to_cv_scalars).erode(nil, 3).dilate!(nil, 5)
              windows[step][i].show img

              values << [img.count_non_zero / (total_pixels * 0.95), 1.0].min
            end
          end
        end
      end

      p sequence
      handle_keyboard_input
    end
  end


  def region_for_step(step)
    width = capture.width / steps
    height = capture.height

    CvRect.new(step * width, 0, width, height)
  end

  def handle_keyboard_input
    key = GUI::wait_key(1)
    exit if key == ESCAPE_KEY
  end
end

config = ARGV.first
App.run
