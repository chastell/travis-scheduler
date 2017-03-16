namespace :db do
  desc "Create and migrate the database"
  task :create do
    env   = ENV["ENV"] || 'test'
    abort "Cannot run rake db:create in production." if env == 'production'

    # TODO
    # url   = "https://raw.githubusercontent.com/travis-ci/travis-migrations/master/db/main/structure.sql"
    url   = "https://raw.githubusercontent.com/travis-ci/travis-migrations/sf-queueable_jobs/db/main/structure.sql"
    file  = 'db/structure.sql'
    system "curl -fs #{url} -o #{file} --create-dirs"
    abort "failed to download #{url}" unless File.exist?(file)

    sh "createdb travis_#{env}" rescue nil
    sh "psql -q travis_#{env} < #{file}"
  end
end
