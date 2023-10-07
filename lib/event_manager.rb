require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new

civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0, 5]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def clean_phone_number(num)
  numbers = (0..9).to_a.map(&:to_s)
  num_s = (num.to_s.split('').select { |x| numbers.include?(x) }).join('')
  if num_s.length == 10
    num_s
  elsif num_s == 11 && num_s[0] == '1'
    num_s[1, 10]
  else
    'bad number'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
days_of_the_week = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]

contents.each do |row|
  id = row[0]

  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  # legislators = legislators_by_zipcode(zipcode)

  phone_number = clean_phone_number(row[:homephone])

  # puts phone_number

  date = Time.strptime("20#{row[:regdate]}", '%Y/%d/%m %H:%M')
  puts "#{id}. Name: #{name}"
  puts "Registration date: #{days_of_the_week[date.wday.to_i-1]}, #{date.year}/#{date.month}/#{date.day}"
  puts "Registration time: #{date.hour}:#{date.min}"
  puts "Phone number: #{phone_number}"
  puts "Zipcode: #{zipcode}\n\n"
  # form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)
end
