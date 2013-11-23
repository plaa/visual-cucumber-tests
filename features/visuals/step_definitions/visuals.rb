require 'oily_png'
require 'fileutils'


VISUAL_DELTA = 0.0  # Allowed ratio of pixels in the image to be different
COLOR_DELTA = 1     # Allowed difference in each color channel before deeming pixel different


if $0 == __FILE__
  def Given(x)
  end
  def Then(x)
  end
end


Given(/^my browser resolution is (\d+)x(\d+)$/) do |x, y|
  set_resolution(x.to_i, y.to_i)
end


Then(/^I should see the contents of "(.*?)"$/) do |file|
  file = "features/visuals/#{file}"
  expected_png = read_binary_file(file)
  
  diff = 9999
  count = 0
  while diff > VISUAL_DELTA && count < 5
    actual_png = browser.screenshot.png
    diff = compare_png(expected_png, actual_png)
    count += 1
    if diff > VISUAL_DELTA
      sleep 0.5
    end
  end
  
  if diff > VISUAL_DELTA
    dirname = "output/screenshots"
    timestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S-%L")
    filebase = "#{dirname}/screenshot_#{timestamp}"
    expected_file = filebase + "_expected.png"
    actual_file = filebase + "_actual.png"
    write_binary_file(expected_file, expected_png)
    write_binary_file(actual_file, actual_png)
    
    embed expected_file, 'image/png', "Expected" if defined? embed
    embed actual_file, 'image/png', "Actual" if defined? embed
    raise "Visual appearance differed from expected by #{diff}% of pixels   expected = #{expected_file}  actual = #{actual_file}"
  end
  
end

def read_binary_file(file)
  File.open(file, "rb") { |f| f.read }
end

def write_binary_file(file, content)
  dir = File.dirname(file)
  FileUtils.mkdir_p dir unless File.directory?(dir)
  File.open(file, "wb") { |f| f.write content }
end

def compare_png(png_a, png_b)
  a = ChunkyPNG::Image.from_blob(png_a)
  b = ChunkyPNG::Image.from_blob(png_b)
  raise "Dimensions do not match: a = #{a.width}x#{a.height}  b = #{b.width}x#{b.height}" if a.width != b.width || a.height != b.height

  diff = 0
  a.height.times do |y|
    a.row(y).each_with_index do |ap, x|
      bp = b[x,y]
      if ap != bp && ChunkyPNG::Color::a(ap) == 255 && ChunkyPNG::Color::a(bp) == 255
        if (ChunkyPNG::Color::r(ap) - ChunkyPNG::Color::r(bp)).abs > COLOR_DELTA || 
          (ChunkyPNG::Color::g(ap) - ChunkyPNG::Color::g(bp)).abs > COLOR_DELTA || 
          (ChunkyPNG::Color::b(ap) - ChunkyPNG::Color::b(bp)).abs > COLOR_DELTA
            diff += 1
        end
      end
    end
  end
  diff.to_f / (a.width * a.height)
end


def set_resolution(request_x, request_y)
  dim = browser.execute_script("return [document.body.clientWidth, document.body.clientHeight];")
  current_x = dim[0]
  current_y = dim[1]
  return if current_x == request_x && current_y == request_y
    
  x = request_x
  y = request_y
  10.times do
    browser.driver.manage.window.resize_to(x, y)
    browser.driver.manage.window.move_to(0,0)
    sleep 0.1
    dim = browser.execute_script("return [document.body.clientWidth, document.body.clientHeight];")
    current_x = dim[0]
    current_y = dim[1]
    return if current_x == request_x && current_y == request_y
    x += (request_x - current_x)
    y += (request_y - current_y)
  end
    
  raise "Unable to set browser size to #{request_x}x#{request_y}"
end



#
# Helper function:  Run this file with two file arguments to print out their image difference
#
if $0 == __FILE__
  if ARGV.length != 2
    Kernel.puts "Usage:  ruby visuals.rb <img1> <img2>"
    exit 1
  end
  file_a = read_binary_file(ARGV[0])
  file_b = read_binary_file(ARGV[1])
  diff = compare_png(file_a, file_b)
  Kernel.puts "Diff: #{diff}"
end

