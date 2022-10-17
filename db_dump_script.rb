#!/usr/bin/env ruby

class DbDumpRunner

  puts "Welcome to the db dumper, before you begin, make sure you shut down your server so this script works properly"
  puts "----------------------------------------------------------------------------------------------------------------------------"

  if File.file?("latest.dump")
    File.delete("latest.dump")
    puts "Deleted existing db dump file"
  else
    puts "No existing db dump file found...continuing script"
  end

  puts "----------------------------------------------------------------------------------------------------------------------------"

  puts "Is your local server stopped?"

  server_stopped = gets.chomp

  if server_stopped.downcase == "y" || server_stopped.downcase == "yes"
    puts 'What is the name of your heroku app?'

    app_name = gets

    system("heroku pg:backups:capture --app #{app_name}")

    system("heroku pg:backups:download --app #{app_name}")

    puts 'Your database has been backed up and latest.dump file created'

    system("scripts/restore latest.dump")

    Plan.destroy_all

    puts "Destroyed all plans"

    Operator.all.map {|operator| operator.push_notification_certificate.detach}

    puts "Detached operator push notifications"

    User.create!(email: "testadmin@jellyswitch.com", name: "Test Admin", password: "pizza123", password_confirmation: "pizza123", role: "admin", operator_id: 1, approved: true)

    puts "Created a new user"

    Plan.create!(name: "Test Plan", operator_id: 1, interval: "monthly", amount_in_cents: 13500, visible: true, available: true, plan_type: "individual", always_allow_building_access: true)

    puts "New plan created, need to add a location in the browser!!"

  else
    puts "Please stop your server, close logs, and exit console first, then rerun this script"
    exit!
  end
end