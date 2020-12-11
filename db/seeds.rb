# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "SEEDing Database and Camunda Engine with users and groups"

require "benchmark"

CustomElasticSearchConfig.initalize_searchkick_indexes

CamundaInitializer.new.sync_camunda_workflows_to_db

g_admin = Group.create(name: "admin")
g_srs = Group.create(name: "srs")
g_tomsy = Group.create(name: "tomsy")
g_dsb = Group.create(name: "DSB")

["process_abuse_report", "dsb_premium_post"].each { |k| Workflow::ProcessDefinition.find_by!(key: k).groups << g_dsb }
["event_planning", "external_requirements"].each { |k| Workflow::ProcessDefinition.find_by!(key: k).groups << g_tomsy }
["initial_meeting_invention", "patent_application"].each { |k| Workflow::ProcessDefinition.find_by!(key: k).groups << g_srs }

# Our superadmin
User.create(email: "admin@uni-jena.example.org", password: "password", firstname: "Admin", lastname: "User").groups << g_admin
# Our no-access user
User.create(email: "no_group@uni-jena.example.org", password: "password", firstname: "No", lastname: "Group")

User.create(email: "dsb@uni-jena.example.org", password: "password", firstname: "DSB", lastname: "Nutzer").groups << g_dsb
User.create(email: "dsb-boss@uni-jena.example.org", password: "password", firstname: "DSB", lastname: "Boss").groups << g_dsb

User.create(email: "srs_user@uni-jena.example.org", password: "password", firstname: "SRS", lastname: "User").groups << [g_srs]

Faker::Config.locale = :de
# Create Person Dossier definition with fields and some example dossiers
person_dd = DossierDefinition.create(
  identifier: "person",
  label: "Person",
  description: "Person welche in Maßnahmen referenziert werden kann."
)
if person_dd
  person_dd.fields.create(
    [{
      identifier: "email", label: "E-Mail",
      position: 1, content_type: DossierDefinitionField.content_types[:string],
      required: true, recommended: false, unique: true
    }, {
      identifier: "name", label: "Name",
      position: 2, content_type: DossierDefinitionField.content_types[:string],
      required: true, recommended: false, unique: false
    }, {
      identifier: "phone", label: "Telefon",
      position: 3, content_type: DossierDefinitionField.content_types[:string],
      required: false, recommended: false, unique: false
    }, {
      identifier: "address", label: "Adresse",
      position: 4, content_type: DossierDefinitionField.content_types[:string],
      required: false, recommended: false, unique: false
    }, {
      identifier: "organization", label: "Organisation",
      position: 5, content_type: DossierDefinitionField.content_types[:string],
      required: false, recommended: true, unique: false
    }, {
      identifier: "newsletter", label: "Newsletter",
      position: 6, content_type: DossierDefinitionField.content_types[:boolean],
      required: false, recommended: false, unique: false
    }, {
      identifier: "rating", label: "Bewertung",
      position: 7, content_type: DossierDefinitionField.content_types[:integer],
      required: false, recommended: false, unique: false
    }, {
      identifier: "birthday", label: "Geburtstag",
      position: 8, content_type: DossierDefinitionField.content_types[:date],
      required: false, recommended: false, unique: false
    }, {
      identifier: "notes", label: "Notizen",
      position: 9, content_type: DossierDefinitionField.content_types[:text],
      required: false, recommended: false, unique: false
    }]
  )

  person_dd.update(title_fields: ["name"], subtitle_fields: ["email", "organization"])

  200.times do
    person_name = Faker::Name.name
    person_field_data = {
      "email" => Faker::Internet.unique.email(name: person_name),
      "name" => person_name
    }
    person_field_data_optional = {
      "phone" => Faker::PhoneNumber.unique.phone_number_with_country_code,
      "address" => Faker::Address.full_address,
      "organization" => Faker::University.name,
      "newsletter" => [true, false].sample,
      "rating" => (1..10).to_a.sample,
      "birthday" => Faker::Date.between(from: 80.years.ago, to: 18.years.ago),
      "notes" => Faker::Lorem.paragraphs(number: (1..5).to_a.sample, supplemental: true).map { |text| "<p>#{text}</p>" }.join
    }
    person_field_data_optional.each { |key, value| person_field_data[key] = value if [true, false].sample }

    Dossier.create(definition: person_dd, field_data: person_field_data, created_by: User.all.sample)
  end

  User.all.each do |user|
    person_field_data = {
      "email" => user.email,
      "name" => "#{user.firstname} #{user.lastname}",
      "phone" => "+49 3641 9-300",
      "address" => "Fürstengraben 1, 07743 Jena, Germany",
      "organization" => "Friedrich-Schiller-Universität Jena",
      "newsletter" => [true, false].sample,
      "rating" => (1..10).to_a.sample,
      "birthday" => Faker::Date.between(from: 80.years.ago, to: 18.years.ago),
      "notes" => Faker::Lorem.paragraphs(number: (1..5).to_a.sample, supplemental: true).map { |text| "<p>#{text}</p>" }.join
    }
    Dossier.create(definition: person_dd, field_data: person_field_data, created_by: User.all.sample)
  end
end

# Create classified Dossier definition with fields and some example dossiers
classified_dd = DossierDefinition.create(
  identifier: "classified",
  label: "Kleinanzeige",
  description: "Steht für eine Kleinanzeige auf dem Schwarzen Brett."
)
if classified_dd
  classified_dd.fields.create(
    [{
      identifier: "number", label: "Nummer",
      position: 1, content_type: DossierDefinitionField.content_types[:string],
      required: true, recommended: false, unique: true
    }, {
      identifier: "title", label: "Titel",
      position: 2, content_type: DossierDefinitionField.content_types[:string],
      required: false, recommended: true, unique: false
    }, {
      identifier: "url", label: "URL",
      position: 3, content_type: DossierDefinitionField.content_types[:string],
      required: false, recommended: false, unique: false
    }, {
      identifier: "text", label: "Text der Anzeige",
      position: 4, content_type: DossierDefinitionField.content_types[:text],
      required: false, recommended: false, unique: false
    }, {
      identifier: "status", label: "Status",
      position: 5, content_type: DossierDefinitionField.content_types[:integer],
      required: false, recommended: false, unique: false
    }]
  )

  classified_dd.update(title_fields: ["title"], subtitle_fields: ["number", "text"])

  200.times do
    classified_number = Faker::Number.unique.number(digits: 10)
    classified_field_data = {
      "number" => classified_number,
      "title" => Faker::Lorem.unique.words(number: (1..5).to_a.sample).join(" "),
      "url" => Faker::Internet.url(scheme: "https", host: "www.schwarzes-brett.example.org", path: "/#{classified_number}"),
      "text" => Faker::Lorem.paragraphs(number: (1..5).to_a.sample, supplemental: true).map { |text| "<p>#{text}</p>" }.join,
      "status" => (0..1).to_a.sample
    }

    Dossier.create(definition: classified_dd, field_data: classified_field_data, created_by: User.all.sample)
  end
end

# Create first entries to avoid exceptions from searching an empty Database
user = User.first
ambition = Interactors::AmbitionInteractor.create(user, {title: "Freigeister in der Flasche halten"})
Interactors::ProcessInteractor.create(Workflow::ProcessDefinition.first, ambition, nil, user)

if ENV["PERFORMANCE_MEASUREMENT"].present?
  dd = DossierDefinition.find(1)
  u = User.find(133235)
  count_start = 1
  count_end = 10000000

  puts Benchmark.measure {
    (count_start..count_end).each do |i|
      Dossier.create(definition: dd,
                     created_by: u,
                     data: {
                       "title" => "#{Faker::Lorem.sentence} - #{i}",
                       "content" => Faker::Lorem.paragraph,
                       "author_email" => Faker::Internet.email,
                       "id" => i
                     })
      print "." if i % 10000 == 0
    end
  }
end
