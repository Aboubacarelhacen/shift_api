require 'faker'

puts 'Seeding roles and users...'

admin = User.find_or_create_by!(email: 'admin@example.com') do |u|
	u.full_name = 'Admin User'
	u.password = 'password'
	u.role = :admin
end

manager = User.find_or_create_by!(email: 'manager@example.com') do |u|
	u.full_name = 'Manager User'
	u.password = 'password'
	u.role = :manager
end

teams = ['Kitchen', 'FrontDesk']
roles = ['Cashier', 'Cook', 'Runner']

employees = []
8.times do |i|
	user = User.find_or_create_by!(email: "employee#{i+1}@example.com") do |u|
		u.full_name = Faker::Name.name
		u.password = 'password'
		u.role = :employee
	end
	e = Employee.find_or_create_by!(email: user.email) do |emp|
		emp.user = user
		emp.first_name = user.full_name.split(' ').first
		emp.last_name = user.full_name.split(' ')[1..]&.join(' ') || 'Employee'
		emp.phone = Faker::PhoneNumber.phone_number
		emp.team = teams.sample
		emp.role = roles.sample
		emp.active = true
	end
	employees << e
end

puts 'Seeding availabilities...'
employees.each do |emp|
	(1..5).each do |weekday|
		Availability.find_or_create_by!(employee: emp, weekday: weekday) do |a|
			a.start_time = '09:00'
			a.end_time = '17:00'
		end
	end
end

puts 'Seeding shifts for one week...'
start_date = Date.today.beginning_of_week
shifts = []
7.times do |d|
	date = start_date + d.days
	[ ['Morning', '09:00', '13:00'], ['Afternoon', '13:00', '17:00'], ['Evening', '17:00', '21:00'] ].each do |title, s, e|
		shift = Shift.create!(
			title: title,
			date: date,
			starts_at: Time.zone.parse("#{date} #{s}"),
			ends_at: Time.zone.parse("#{date} #{e}"),
			location: teams.sample,
			role_required: roles.sample,
			capacity: 3
		)
		shifts << shift
	end
end

puts 'Assigning random employees to shifts...'
shifts.each do |shift|
	candidates = employees.sample(shift.capacity)
	candidates.each do |emp|
		next if ShiftAssignment.exists?(shift: shift, employee: emp)
		begin
			AssignmentValidator.new(shift: shift, employee: emp).call.tap do |res|
				if res.ok
					shift.shift_assignments.create!(employee: emp, created_by_user_id: admin.id)
				end
			end
		rescue => e
			# skip on error
		end
	end
end

puts 'Seeding complete.'
