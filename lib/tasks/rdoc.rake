require 'rdoc/task'

RDoc::Task.new(rdoc: "rdoc", clobber_rdoc: "rdoc:clean", rerdoc: "rdoc:force") do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_dir = "public/rdoc"
  rdoc.rdoc_files.include("*.rb")
  rdoc.markup = "markdown"
  rdoc.before_running_rdoc do
    rdoc.options << "-x"
    rdoc.options << "log/asian.log"
    rdoc.options << "-x"
    rdoc.options << "log/cable.log"
    rdoc.options << "-x"
    rdoc.options << "log/channels.log"
    rdoc.options << "-x"
    rdoc.options << "log/controllers.log"
    rdoc.options << "-x"
    rdoc.options << "log/development.log"
    rdoc.options << "-x"
    rdoc.options << "log/test.log"
    rdoc.options << "-x"
    rdoc.options << "log/production.log"
    rdoc.options << "-x"
    rdoc.options << "db/*"
    rdoc.options << "-x"
    rdoc.options << "bin/*"
    rdoc.options << "-x"
    rdoc.options << "public/*"
    rdoc.options << "-x"
    rdoc.options << "robots"
    rdoc.options << "-x"
    rdoc.options << "restart"
    rdoc.options << "-x"
    rdoc.options << "404.html"
    rdoc.options << "-x"
    rdoc.options << "422.html"
    rdoc.options << "-x"
    rdoc.options << "500.html"
    rdoc.options << "-x"
    rdoc.options << "test/*"
    rdoc.options << "-x"
    rdoc.options << "Gemfile"
    rdoc.options << "-x"
    rdoc.options << "Gemfile.lock"
    rdoc.options << "-x"
    rdoc.options << "Guardfile"
    # rdoc.options << "-x"
    # rdoc.options << "README.md"
    rdoc.options << "-x"
    rdoc.options << "Rakefile"
    rdoc.options << "-x"
    rdoc.options << "coverage/*"
    rdoc.options << "-x"
    rdoc.options << "tmp/*"
    rdoc.options << "-x"
    rdoc.options << "app/assets/*"
    rdoc.options << "-x"
    rdoc.options << "cable/config.ru"
    rdoc.options << "-x"
    rdoc.options << "config.ru"
    rdoc.options << "-x"
    rdoc.options << "daemons.rb.pid"
    rdoc.options << "-x"
    rdoc.options << "lib/csv/*"
    rdoc.options << "-x"
    rdoc.options << "lib/rubocop/*"
    rdoc.options << "-x"
    rdoc.options << "lib/tasks/*"
    # rdoc.options << "-x"
    # rdoc.options << "doc/*"
  end
end
