# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Constant.delete_all

constants = Constant.create([
                              {
                                name:  'verification_method',
                                label: 'Review/inspection',
                                value: 'Review/inspection'
                              },
                              {
                                name:  'verification_method',
                                label: 'Analysis/Simulation',
                                value: 'SimAnalysis/Simulationulation'
                              },
                              {
                                name:  'verification_method',
                                label: 'Test',
                                value: 'Test'
                              },
                            ])

document_types = YAML.load_file("#{Rails.root.to_s}/db/document_types.yml")

DocumentType.delete_all

document_types.each { |label, document_type| DocumentType.create!(document_type) }
