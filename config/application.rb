require 'bundler/setup'

Bundler.require

require 'active_support/core_ext/class/attribute'
module ApplicationHelper; end

Jets.application.configure do
  config.project_name = "rohlik"
  config.mode = "api"

  # config.prewarm.enable = true # default is true
  # config.prewarm.rate = '30 minutes' # default is '30 minutes'
  # config.prewarm.concurrency = 2 # default is 2
  # config.prewarm.public_ratio = 3 # default is 3

  # config.env_extra = 2 # can also set this with JETS_ENV_EXTRA
  config.extra_autoload_paths = [ Jets.root.join('lib') ]

  # config.asset_base_url = 'https://cloudfront.domain.com/assets' # example

  config.cors = true # for '*''
  # config.cors = '*.mydomain.com' # for specific domain

  config.function.timeout = 20
  # config.function.role = "arn:aws:iam::#{Jets.aws.account}:role/service-role/pre-created"
  # config.function.memory_size= 1536

  config.function.environment = {

  }
  # More examples:
  # config.function.dead_letter_queue = { target_arn: "arn" }
  # config.function.vpc_config = {
  #   security_group_ids: [ "sg-1", "sg-2" ],
  #   subnet_ids: [ "subnet-1", "subnet-2" ]
  # }
  # The config.function settings to the CloudFormation Lambda Function properties.
  # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html
  # Underscored format can be used for keys to make it look more ruby-ish.

  # Assets settings
  # config.assets.folders = %w[packs images assets] # default packs images assets
  # config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path , defaults to use s3
  # config.assets.max_age = 3600 # when to expire assets
  # config.assets.cache_control = nil # IE: public, max-age=3600 , max_age is a shorter way to set cache_control.
end