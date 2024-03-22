#!/usr/bin/env ruby

# Imports
require 'openssl'
require 'jwt'     # https://rubygems.org/gems/jwt

class GenerateJWT
  PERSONAL_ACCESS_TOKEN = ENV['PERSONAL_ACCESS_TOKEN']
  PRIVATE_KEY_FILENAME  = File.join(Rails.root, '.ssh', 'id_rsa')
  APP_IDENTIFIER        = ''
  @app_identifier       = APP_IDENTIFIER
  @private_key_filename = nil
  @jwt                  = nil

  def set_app_identifier(app_identifier)
    @app_identifier = app_identifier
  end

  def set_private_key_filename(private_key_filename)
    @private_key_filename = private_key_filename
  end

  def get_jwt
    return @jwt
  end

  def generate_jwt(app_identifier = @app_identifier, private_key_filename = @rivate_key_filename)
    @jwt          = nil

    if File.readable?(private_key_filename)
      # Private key contents
      private_pem = File.read(private_key_filename)
      private_key = OpenSSL::PKey::RSA.new(private_pem)

      # Generate the JWT
      payload     = {
                      # issued at time
                      iat: Time.now.to_i,

                      # JWT expiration time (10 minute maximum)
                      exp: Time.now.to_i + (10 * 60),

                      # GitHub App's identifier
                      iss: @app_identifier
                    }

      @jwt        = JWT.encode(payload, private_key, "RS256")
    end

    return @jwt
  end

  def initialize(app_identifier = nil, private_key_filename = nil)
    @app_identifier       = app_identifier       if app_identifier.present?
    @private_key_filename = private_key_filename if private_key_filename.present?

    generate_jwt if @app_identifier.present? && @private_key_filename.present?
  end
end
