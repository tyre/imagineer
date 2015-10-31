## Requires: ruby, imagemagick (`convert`)
#
# Outputs an input file's pixels into another file as an Elixir data structure.
# It will be a list of lists, whose sublists contain tuples of the image's
# channels.
# This is useful to test parsing.
# This

X_COORDINATE = "x_coordinate".freeze
Y_COORDINATE = "y_coordinate".freeze
PIXELS = "pixels".freeze
COMMA = ",".freeze
OPEN_BRACKET = '['.freeze
CLOSE_BRACKET = ']'.freeze
LINE_REGEX = /\A(?<#{X_COORDINATE}>\d+),(?<#{Y_COORDINATE}>\d+): \((?<#{PIXELS}>[\d\.,]+)\).*\z/
FLOAT_REGEX = /\./
image_file_name = "./" << ARGV.first
pixels = Array.new

pixel_inspection = `convert #{image_file_name} txt:-`

pixel_inspection.split("\n").each do |line|
  match_data = LINE_REGEX.match(line)
  if match_data
    point_pixels = match_data[PIXELS].split(COMMA).map do |channel|
      if channel =~ FLOAT_REGEX
        channel.to_f
      else
        channel.to_i
      end
    end
    row = pixels[match_data[X_COORDINATE].to_i] ||= []
    row[match_data[Y_COORDINATE].to_i] = point_pixels
  end
end
pixels_file_name = ARGV[1] || '../../tmp/' << File.basename(image_file_name, '.*') << '.pixels'

# Now write to the given filename or the tmp directory of this repo
File.open(pixels_file_name, 'w') do |f|
  f << OPEN_BRACKET
  f << pixels.reduce([]) do |row_strings, row|
    row_string = '[' << row.reduce([]) do |pixel_strings, pixel|
      pixel_strings << "{#{pixel.join(COMMA)}}"
    end.join(COMMA) << CLOSE_BRACKET
    row_strings << row_string
  end.join(",\n")
  f << CLOSE_BRACKET
end
