require 'rubygems'
require 'mechanize'
require 'ap'
require 'chronic'
require 'pry'

#target_date = Date.new(2014,02,05)

def debug(object)
  ap object if false
end

while true 
  target_date = Date.today + 1

  begin
    a = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    a.get('https://www.dmv.ca.gov/foa/clear.do?goTo=officeVisit&localeName=en') do |page|
      debug page

      page.form_with(name: 'ApptForm') do |form|
        form.officeId = 503
        form.radiobutton_with(name: 'numberItems').check
        form.checkbox_with(name: 'taskDL').check
        form.firstName = 'SIMON'
        form.lastName = 'MATHIEU'
        form.telArea = '650'
        form.telPrefix = '455'
        form.telSuffix = '2478'
        debug form

        apointment_page = form.submit
        debug apointment_page
        date = apointment_page.search(".alert").last.text
        File.write("./apointment.html", apointment_page.body)
        date = date.split(", ")[1..-1].join(" ")
        date = Chronic.parse(date).to_date

        puts "Target date: #{target_date}"
        puts "Available date: #{date}"

        if date <= target_date
          form = apointment_page.form_with(action: '/wasapp/foa/reviewOfficeVisit.do')
          confirm_page = form.submit
          debug "confirm page"
          debug form
          debug "\n"*20
          debug confirm_page

          File.write("./confirm.html", confirm_page.body)

          form = confirm_page.form_with(action: '/wasapp/foa/confirmOfficeVisit.do')
          result_page = form.submit
          debug result_page
          File.write("./results.html", result_page.body)
          puts "Apointment found!"
          exit 
        else
          60.times do |i|
            puts
            $stdout.write "#{60 - i}, "
            sleep 1
          end
        end
      end
    end
  rescue => e
    ap e
  end
end
