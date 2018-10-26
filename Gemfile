source 'https://rubygems.org' do
  gem 'jets'
  gem 'prometheus-client'

  group :development, :test do
    # Call 'byebug' anywhere in the code to stop execution and get a debugger console
    gem 'pry-byebug', platforms: %i[mri mingw x64_mingw]
    gem 'rack'
    gem 'shotgun'
  end

  group :test do
    gem 'minitest'
    gem 'rspec', require: false # rspec test group only or we get the "irb: warn: can't alias context from irb_context warning" when starting jets console
  end
end
