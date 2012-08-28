module Elasticity

  class NoBucketError < StandardError; end
  class NoDirectoryError < StandardError; end

  class SyncToS3

    attr_reader :access_key
    attr_reader :secret_key
    attr_reader :bucket_name

    def initialize(bucket, access=nil, secret=nil)
      @access_key = get_access_key(access)
      @secret_key = get_secret_key(secret)
      @bucket_name = bucket
    end

    def sync(local, remote)
      if !s3.directories.map(&:key).include?(@bucket_name)
        raise NoBucketError, "Bucket '#@bucket_name' does not exist"
      end

      if !File.exist?(local) || !File.directory?(local)
        raise NoDirectoryError, "Directory '#{local}' does not exist or is not a directory"
      end

      sync_dir(local, remote)
    end

    private

    def sync_dir(local, remote)

    end

    def s3
      @connection ||= Fog::Storage.new({
        :provider => 'AWS',
        :aws_access_key_id => @access_key,
        :aws_secret_access_key => @secret_key
      })
    end

    def get_access_key(access)
      return access if access
      return ENV['AWS_ACCESS_KEY_ID'] if ENV['AWS_ACCESS_KEY_ID']
      raise MissingKeyError, 'Please provide an access key or set AWS_ACCESS_KEY_ID.'
    end

    def get_secret_key(secret)
      return secret if secret
      return ENV['AWS_SECRET_ACCESS_KEY'] if ENV['AWS_SECRET_ACCESS_KEY']
      raise MissingKeyError, 'Please provide a secret key or set AWS_SECRET_ACCESS_KEY.'
    end

  end

end