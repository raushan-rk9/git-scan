#!/usr/bin/env ruby
# Copyright 2021 Patmos Engineering, Inc.
# All Rights Reserved.
# install-certificates.rb

# Generate and install certificates

# Changes
#   08-3-21: P.C. Written

# Imports
require 'rubygems'
require 'byebug'

dry_run       = ''
dont_get_cert = false
dont_copy     = false
verbose       = false
debug         = false

class String
  def present?
    (self.nil? || self == '')
  end
end

if ARGV.length > 0
  ARGV.each do |argument|
    if argument  =~ /^--.+$/
      if argument =~ /^--dry_run$/i
        dry_run       = '--dry-run'
      end

      if argument =~ /^--verbose$/i
        verbose       = true
      end

      if argument =~ /^--dont_get_cert$/i
        dont_get_cert = true
      end

      if argument =~ /^--dont_copy$/i
        dont_copy     = true
      end

      if argument =~ /^--debug$/i
        debug         = true
      end
    end
  end
end

if debug
  byebug
end

unless dont_get_cert
  puts('Executing /etc/init.d/apache2 stop')                           if verbose
  system('/etc/init.d/apache2 stop')
  puts('Executing certbot certonly -n -d acs-patmos.com --standalone') if verbose

  if verbose
    system("certbot certonly -n -d acs-patmos.com --standalone #{dry_run}")
  else
    system("certbot certonly -n -d acs-patmos.com --standalone #{dry_run}")
  end

  puts('Executing /etc/init.d/apache2 start') if verbose
  system('/etc/init.d/apache2 start')         unless dry_run.present?
end

unless dont_copy
  puts('Executing cp -r /etc/letsencrypt ~paul/certificates') if verbose

  unless dry_run.present?
    if verbose
      system('cp -rv /etc/letsencrypt ~paul/certificates')
    else
      system('cp -r /etc/letsencrypt ~paul/certificates')
    end
  end

  puts('Executing cd ~paul/certificates && sudo find . -exec chown paul \{\} \; -exec chgrp paul \{\} \;') if verbose

  unless dry_run.present?
  system('cd ~paul/certificates && sudo find . -exec chown paul \{\} \; -exec chgrp paul \{\} \;')
  end

  puts('Executing cat ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem > ~paul/certificates/cockpit/1-acs-com.cert') if verbose

  unless dry_run.present?
    system('cat ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem > ~paul/certificates/cockpit/1-acs-com.cert')
  end

  puts('Executing cp ~paul/certificates/cockpit/1-acs-com.cert /etc/cockpit/ws-certs.d/1-acs-com.cert') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/cockpit/1-acs-com.cert /etc/cockpit/ws-certs.d/1-acs-com.cert')
    else
      system('cp ~paul/certificates/cockpit/1-acs-com.cert /etc/cockpit/ws-certs.d/1-acs-com.cert')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/gitlab/ssl/acs-patmos.com.crt') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/gitlab/ssl/acs-patmos.com.crt')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/gitlab/ssl/acs-patmos.com.crt')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/gitlab/ssl/acs-patmos.com.key') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/gitlab/ssl/acs-patmos.com.key')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/gitlab/ssl/acs-patmos.com.key')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/gitlab/trusted-certs/acs-patmos.com.crt') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/gitlab/trusted-certs/acs-patmos.com.crt')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/gitlab/trusted-certs/acs-patmos.com.crt')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/gitlab/ssl/acs-patmos.com.key') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/gitlab/ssl/acs-patmos.com.key')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/gitlab/ssl/acs-patmos.com.key')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/nginx/acs-patmos.crt') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/nginx/acs-patmos.crt')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/nginx/acs-patmos.crt')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/nginx/acs-patmos.key') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/nginx/acs-patmos.key')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/nginx/acs-patmos.key')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/docker/acs-patmos-cert.pem') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/docker/acs-patmos-cert.pem')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/docker/acs-patmos-cert.pem')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/docker/acs-patmos-key.pem') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/docker/acs-patmos-key.pem')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/docker/acs-patmos-key.pem')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/apache2/certs/') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/apache2/certs/')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/fullchain.pem /etc/apache2/certs/')
    end
  end

  puts('Executing cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/apache2/keys/') if verbose

  unless dry_run.present?
    if verbose
      system('cp -v ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/apache2/keys/')
    else
      system('cp ~paul/certificates/letsencrypt/live/acs-patmos.com/privkey.pem /etc/apache2/keys/')
    end
  end
end
