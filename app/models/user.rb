class User < ActiveRecord::Base
  DEFAULT_TOKEN_EXPIRE = 1.day

  validates_presence_of :username
  validates_presence_of :password
  validates_presence_of :role
  validates_uniqueness_of :username
  validates_inclusion_of :role, in: ["ADMIN", "OPER"]
  has_many :access_tokens

  before_save :encrypt_password

  def as_json(opts={})
    {
      username: username,
      role: role
    }
  end

  # Encrypt password before saving, but only for new users or when setting new password
  def encrypt_password
    if self.id.nil? || self.password_changed?
      self.password = BCrypt::Password.create(self.password)
    end
  end

  # Validate password for current user
  def authenticate(given_password)
    password_object = BCrypt::Password.new(self.password)
    if password_object == given_password
      token_object = generate_token
      return token_object.token
    else
      return false
    end
  end

  # Generate random token for use with authentication
  def generate_token
    token_hash = SecureRandom.hex
    token_hash.force_encoding('utf-8')
    access_tokens.create(token: token_hash, token_expire: Time.now + DEFAULT_TOKEN_EXPIRE)
  end

  # Clear all tokens that have expired
  def clear_expired_tokens
    access_tokens.where("token_expire < ?", Time.now).destroy_all
  end

  # Validate a given token against token list for current user
  # First clear all expired tokens. This means all available tokens are valid.
  def validate_token(provided_token)
    clear_expired_tokens
    token_object = access_tokens.find_by_token(provided_token)
    return false if !token_object
    token_object.update_attribute(:token_expire, Time.now + DEFAULT_TOKEN_EXPIRE)
    true
  end

  # Returns all currently valid tokens for user
  def valid_tokens
    clear_expired_tokens
    access_tokens.pluck(:token)
  end

  def has_right?(permission_level)
    return true if permission_level == "admin" && role == "ADMIN"
    return true if permission_level == "oper" && ["ADMIN", "OPER"].include?(role)
    return false
  end

  def primary_registered_card_count
    Card.where(primary_registrator_username: self.username).where.not(primary_registrator_end: nil).count
  end

  def secondary_registered_card_count
    Card.where(secondary_registrator_username: self.username)
        .where.not(secondary_registrator_end: nil)
        .count
  end

  # primary_register_username not u.name
  # primary_register_end not nil
  # secondary_registrator_end nil
  # AND
  # (
  # secondary_registrator_username nil
  # OR
  # secondary_register_start expired
  # )
  def available_for_secondary_registration_count
    Card.where.not(primary_registrator_username: self.username)
        .where.not(primary_registrator_end: nil)
        .where(secondary_registrator_end: nil)
        .where("secondary_registrator_start IS NULL OR (now() > secondary_registrator_start + interval '1' day)")
        .count
  end

end
