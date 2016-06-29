# Prod/dev seeds
sources = [
  { name: 'reddit', url: 'https://reddit.com/r/random.json' },
  { name: 'twitter', url: 'https://twitter.com' }
]

sources.each { |s| puts s; Source.create(name: s[:name], url: s[:url] ) }

# Begin dev seeds
unless Rails.env.production?
end
