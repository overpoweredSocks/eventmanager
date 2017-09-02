require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

ZIPCODE_LENGTH = 5

def clean_zip(zip)
	if zip.length < ZIPCODE_LENGTH
    dif = ZIPCODE_LENGTH - zip.length
	  zip = "#{"0" * dif}#{zip}" 	
	elsif zip.length > ZIPCODE_LENGTH
		zip = zip[0, ZIPCODE_LENGTH - 1]
  end
	zip
end

def get_legislators(zip_code)
	Sunlight::Congress::Legislator.by_zipcode(zip_code)
end

def save_files(id, form_letter) 
	Dir.mkdir("output") unless Dir.exists?("output")
	filename = "output/thanks_#{id}.html"
	File.open(filename, 'w') { |file| file.puts form_letter }
end

# analyze event_attendes.csv and write thank you details to 
# output directory
puts "Event Manager Initialized!"
contents = CSV.open("event_attendees.csv", headers: true, 
									 header_converters: :symbol)
template_letter = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)


contents.each do |row|
	name = row[:first_name]
	zip_code = clean_zip(row[:zipcode].to_s)
	legislators = get_legislators(zip_code)
	form_letter = erb_template.result(binding)
	save_files(row[0], form_letter)
end




