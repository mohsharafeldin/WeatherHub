require 'xcodeproj'

project_path = 'WeatherHub.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.first

# Create Repositories group if it doesn't exist
main_group = project.main_group.children.find { |g| g.name == 'WeatherHub' || g.path == 'WeatherHub' }
repos_group = main_group.children.find { |g| g.name == 'Repositories' || g.path == 'Repositories' }
if repos_group.nil?
  repos_group = main_group.new_group('Repositories', 'Repositories')
end

# Add files
files_to_add = [
  'WeatherHub/Repositories/WeatherRepository.swift',
  'WeatherHub/Repositories/FavouriteLocationRepository.swift'
]

files_to_add.each do |file_path|
  # Avoid adding duplicates
  filename = File.basename(file_path)
  existing = repos_group.children.find { |c| c.name == filename || c.path == filename }
  if existing.nil?
    file_ref = repos_group.new_file(filename)
    target.add_file_references([file_ref])
    puts "Added #{filename} to Xcode project."
  else
    puts "#{filename} is already in the project."
  end
end

project.save
puts "Project saved."
