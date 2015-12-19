# CalGen - A simple calendar generator

Generate a simple calendar in PDF form. I've created this in 2014, when I tried a few commercially
available Mac apps to do the same thing but failed to get the result I wanted.

It creates a layout suitable for A4 photo calendars (portrait) which works great for 11cm photos,
but it should be easily tweakable with a bit of ruby knowledge. All visual parameters as well as
the texts used to generate the weekdays and months, are hardcoded in the app. I know that sounds
kinda stupid, but this is a quick hack, after all. I'm only making this available for people to
look and and use it as a starting point for their own experiments. It's probably also a good
demonstration of the beautiful simplicity of **prawn**, the gem I'm using to generate the PDF.

## Usage

Please note that this currently doesn't come with a proper gem/binary version, so you'll have to
do most things manually:

- Clone the repo
- run bundle install to install the dependencies
- run ruby calgen.rb to run the generator.

### Options

- use `-y` or `--year` to specify the year the calendar should be generated for. Leave it out and
get a calendar for the current year.
- use `-h` or `--holidays` to specify a file or a URL to get either a yaml file (see
[free_days.yml](free_days.yml) for an example on how to format it) or an ics (iCal) file. calgen
simply takes all events or dates in the file and marks them as holidays (in the same way weekends
are marked).
- use `-o` or `--outfile` to specify a filename for the generated pdf. If omitted, it will write a
file named `calendar.pdf` in the current directory.

## Credits

This currently contains one specific font file from the open source Bitstream Vera variant called
DejaVu. Find out more at their [Website](http://dejavu-fonts.org/).

I'm using the [prawn](https://github.com/prawnpdf/prawn) library for pdf generation.

I'm also using the [iCalendar](https://github.com/icalendar/icalendar) gem for parsing iCal files for holiday lists

## License

SEE [LICENSE](LICENSE)
