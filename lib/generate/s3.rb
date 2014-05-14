class Generate::S3
  def self.save(path, content) 
    new_object(path.downcase).tap do |object|
      object.content_disposition = 'inline'
      object.content = content
      object.save
    end
  end

  def self.new_object(path)
    bucket.objects.build(path)
  end

  def self.bucket
    bucket = Rails.application.config.s3_bucket
    key    = Rails.application.config.s3_key
    secret = Rails.application.config.s3_secret

    service = S3::Service.new(access_key_id: key, 
      secret_access_key: secret,
      use_ssl: true)
    service.buckets.find(bucket) 
  end
end
