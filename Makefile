
deploy:
	sam package --template-file template.yaml --output-template-file packaged-template.yml --s3-bucket $(AWS_S3_BUCKET)
	aws cloudformation deploy --template-file packaged-template.yml --stack-name rohlik-exporter-prod --capabilities CAPABILITY_IAM
