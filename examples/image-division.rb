#!/usr/bin/env ruby

require "opencv"
require_relative "../lib/hsv"
require 'byebug' if ENV['DEBUG']

include OpenCV

class App
  ESCAPE = 1048603

  attr_reader :capture,:windows, :rows, :columns

  def self.run
    new.run
  end

  def initialize(columns: 2, rows: 2)
    @capture = CvCapture::open
    @rows, @columns = Integer(rows), Integer(columns)
    set_windows
  end

  def set_windows
    image = capture.query
    width, height = image.width, image.height

    piece_width = width / columns
    piece_height = height / rows

    hspace = 10
    vspace = 30

    @windows = (0...rows).map do |row|
      (0...columns).map do |column|
        id = ((row * columns) + column).to_s
        window = GUI::Window.new(id)
        x = column * piece_width + hspace * column
        y = row * piece_height + vspace * row
        p "Window #{id} at (#{x},#{y}) size: #{piece_width}x#{piece_height}"
        window.move  x, y

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

      each_window do |window, row, col|
        image.set_roi(CvRect.new(width * col, height * row, width, height)) do |part|
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

App.new(columns: ARGV[0] || 2, rows: ARGV[1] || 2).run
