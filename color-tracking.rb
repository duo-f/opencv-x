#!/usr/bin/env ruby

require "opencv"
include OpenCV

ESCAPE = 1048603

capture = CvCapture::open
h, s, v = [22,89], [139,255], [67,165] # verde (el de la carpeta)

window = GUI::Window.new("0")
window.set_trackbar("h", 255, h.first) { |vv| h[0] = vv }
window.set_trackbar("s", 255, s.first) { |vv| s[0] = vv }
window.set_trackbar("v", 255, v.first) { |vv| v[0] = vv }
window.set_trackbar("H", 255, h.last) { |vv| h[1] = vv }
window.set_trackbar("S", 255, s.last) { |vv| s[1] = vv }
window.set_trackbar("V", 255, v.last) { |vv| v[1] = vv }

windows = [
           GUI::Window.new("1"),
           GUI::Window.new("2"),
           GUI::Window.new("3"),
           GUI::Window.new("4")
          ]

loop do
  steps = []
  steps << capture.query
  steps << steps.last.BGR2HSV
  steps << steps.last.in_range(CvScalar.new(*[h, s, v].map(&:first)), CvScalar.new(*[h,s,v].map(&:last)))

  morph = steps.last.erode(nil, 3)
  morph.dilate!(nil, 8)

  steps << morph

  windows.each.with_index { |w, i| w.show steps[i] }

  # exit if escape
  exit if GUI::wait_key(1) == ESCAPE
end
