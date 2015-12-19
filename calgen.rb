require 'rubygems'
require 'bundler/setup'
require 'prawn'
require 'open-uri'
require 'yaml'
require 'optparse'
require 'icalendar'


options = {outfile: 'calendar.pdf', year: Date.today.year }
OptionParser.new do |opts|
  opts.banner = "Usage: calgen.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on('-y', '--year YEAR', 'Year of Calendar to generate') do |year|
    y = year.to_i
    if y < 1000
      y += 2000
    end
    options[:year] = y
  end
  opts.on('-h', '--holidays FILE', 'ics or yaml with holidays. can also be an URL') do |file|
    options[:holidays_file_or_url] = file
  end
  opts.on('-o', '--outfile FILE', 'output file (will be calendar.pdf if omitted)') do |outfile|
    options[:outfile] = outfile
  end
end.parse!

MONTHS = %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember)
DAYS = %w(Mo Di Mi Do Fr Sa So)

YEAR = options[:year]

EXTRA_MARGIN_VERTICAL = 100
EXTRA_MARGIN_HORIZONTAL = 50

COLOR_NORMAL = "000000"
COLOR_HOLIDAY = "AA0000"

POS_CAL_VERTICAL = 2.5
HEADLINE_SPACE = 50



if options[:holidays_file_or_url]
  holidays = []
  if options[:holidays_file_or_url].match(/.ics$/)
    ical = Icalendar.parse(open(options[:holidays_file_or_url]))
    cal = ical.first
    holidays = cal.events.map{|event| event.dtstart.strftime("%Y-%m-%d") }
  elsif options[:holidays_file_or_url].match(/.yml$/)
    holidays = YAML.load_file('free_days.yml')
  else
    fail("Sorry, your file does not work")
  end
end

pdf = Prawn::Document.new(page_size: 'A4', bottom_margin: EXTRA_MARGIN_VERTICAL)
pdf.font("fonts/DejaVuSerif.ttf")
pdf.stroke_color = "000000"

def color(condition)
  if condition
    COLOR_HOLIDAY
  else
    COLOR_NORMAL
  end
end

# getting max text width for centering boxes

max_text_width = (DAYS + ['30']).inject(0.0) do |max, str|
  [max, pdf.width_of(str)].max
end


12.times do |month|

  pdf.bounding_box([EXTRA_MARGIN_HORIZONTAL,pdf.bounds.height / POS_CAL_VERTICAL], width: pdf.bounds.width - (EXTRA_MARGIN_HORIZONTAL * 2), height: pdf.bounds.height / POS_CAL_VERTICAL) do
    pdf.fill_color = "000000"
    pdf.text(MONTHS[month], align: :center, size: 24)

    col_width = pdf.bounds.width / 7

    box_offset = (col_width - max_text_width) / 2

    row_height = (pdf.bounds.height - HEADLINE_SPACE) / 7


    pdf.bounding_box([0,pdf.bounds.height - HEADLINE_SPACE], :width => pdf.bounds.width) do

      DAYS.each_with_index do |day, i|
        pdf.bounding_box([i * col_width + box_offset, pdf.bounds.height], :width => max_text_width, height: row_height) do
          pdf.fill_color = color(i > 4)
          pdf.text(day, align: :right, valign: :center)

        end
      end
      row = 0
      day = Date.new(YEAR, month + 1, 1)
      while (day.month == month+1) do
        weekday = day.wday - 1
        weekday = 6 if weekday < 0
        if weekday == 0 && day.day > 1
          row += 1
        end
        pdf.bounding_box([weekday * col_width + box_offset, pdf.bounds.height - (row + 1) * row_height], :width => max_text_width, height: row_height) do
          pdf.fill_color = color(weekday > 4 || holidays.include?(day.strftime('%Y-%m-%d')))
          pdf.text(day.day.to_s, align: :right, valign: :center)
        end
        day += 1
      end
    end
  end
  pdf.start_new_page if month < 11
end

pdf.render_file(options[:outfile])
