class User < ActiveRecord::Base
  include Authority::UserAbilities

  has_many :repos, dependent: :destroy
  has_many :followers, dependent: :destroy

  validates_presence_of   :uid, :provider, :name, :auth_token
  validates_uniqueness_of :uid

  def digest
    Digest::MD5.hexdigest("#{login}#{uid}")
  end

  def update_from_omniauth(auth = {})
    token = auth['credentials'] && auth['credentials']['token']
    return unless token
    self[:auth_token] = token
    save
  end

  def self.create_with_omniauth(auth = {})
    return nil unless auth
    user       = User.new

    user.attributes = {
      provider:  auth['provider'],
      uid:       auth['uid'],
      login:     (auth['info'] && auth['info']['nickname'])  || nil,
      name:      (auth['info'] && auth['info']['name'])  || nil,
      email:     (auth['info'] && auth['info']['email'])  || nil,
      image_url: (auth['info'] && auth['info']['image']) || nil,
      auth_token:(auth['credentials'] && auth['credentials']['token']) || nil,
      role:      'author'
    }
    if user.save
      send_email(user[:id]) 
      user
    end
  end

  def self.find_with_omniauth(auth = {})
    return nil unless auth && auth[:uid]
    User.where(uid: auth[:uid]).first
  end

  private
  def self.send_email(user_id)
    UserSignupEmailWorker.perform_async(user_id) 
  end
end
