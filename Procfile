web: bundle exec rails server thin -p $PORT -e $RACK_ENV
worker: bundle exec rake jobs:work
Delayed::Worker.delay_jobs = false