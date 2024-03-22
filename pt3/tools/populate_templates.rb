organization = if ENV.fetch("ORGANIZATION").present?
                 ENV.fetch("ORGANIZATION")
               elsif ENV.fetch("DBNAME").present?
                 ENV.fetch("DBNAME")
               end
db_name      = if ENV.fetch("DBNAME").present?
                 ENV.fetch("DBNAME")
               elsif organization.present?
                 organization
               end

unless organization.present? && db_name.present?
  STDOUT.puts('Missing organization or database name.')
  exit 1
end

result = PopulateTemplates.new.populate_templates(PopulateTemplates::DEFAULT_TEMPLATES_FOLDER,
                                                  'paul@patmos-eng.com',
                                                  organization,
                                                  db_name)

if result.present?
  puts result
  exit(1)
end