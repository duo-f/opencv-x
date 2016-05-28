#!/usr/bin/env ruby

require "opencv"
require_relative "lib/hsv"
require 'byebug' if ENV['DEBUG']

include OpenCV

class App
  ESCAPE = 1048603

  attr_reader :capture,:windows, :rows, :columns

  def self.run
    new.run
  end

  def initialize(rows: 2, columns: 2)
    @capture = CvCapture::open
    @rows, @columns = Integer(rows), Integer(columns)
    set_windows
  end

  def set_windows
    image = capture.query
    width, height = image.width, image.height

    @windows = (0...rows).map do |row|
      (0...columns).map do |column|
        window = GUI::Window.new((column * columns + row).to_s)
        window.move row * height + 5, width * column + 5
        window
      end
    end
  end

  def each_window
    (0...rows).each do |row|
      (0...columns).each do |column|
        yield windows[row][column], row, column
      end
    end
  end

  def run
    loop do
      image = capture.query

      rect = image.get_roi
      width = rect.width / columns
      height = rect.height / rows

      each_window do |window, x, y|
        image.set_roi(CvRect.new(width * x, height * y, width, height)) do |part|
          window.show part
        end
      end

      handle_keyboard_input
    end
  end

  private

  def handle_keyboard_input
    exit if GUI::wait_key(1) == ESCAPE
  end
end

App.new(rows: ARGV[0] || 2, columns: ARGV[1] || 2).run
