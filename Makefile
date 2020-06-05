lint:
	bundle exec rubocop

show_coverage:
	google-chrome coverage/index.html

tests:
	bundle exec rake test
