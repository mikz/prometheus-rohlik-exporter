
deploy:
	#  spotinst does not unpack the whole tar depth, so if dependencies are in vendor/bundle then the last
	# directories are trimmed (like prometheus/client)
	bundle install --standalone --deployment --without development --without test --without web --path ./vendor
	serverless deploy
