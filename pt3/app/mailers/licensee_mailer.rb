class LicenseeMailer < ApplicationMailer
  default from: "pact_cm@airworthinesscert.com"
  layout        "mailer"

  def license_expiring(licensee_id,
                       notify_at = [ 45, 10 ],
                       cc_list   = [
                                      'paul@airworthinesscert.com',
                                      'info@airworthinesscert.com'
                                   ])
    if licensee_id.kind_of?(String)
      @licensee   = Licensee.find_by(identifier: licensee_id)
    else
      @licensee   = Licensee.find_by(id: licensee_id)
    end

    return unless @licensee.present?

    to_list       = @licensee.contact_emails
    today         = Date.today

    return unless notify_at.present? && to_list.present? && @licensee.renewal_date

    notify_at     = notify_at.split(',') if notify_at.kind_of?(String)

    notify_at.each do |at|
      notify_days = at.to_i
      @days       = (@licensee.renewal_date - today).to_i

      next unless @days == notify_days

      message     = mail(template_path: 'licensee_mailer',
                         template_name: 'license_expiring',
                         to:            to_list,
                         cc:            cc_list,
                         subject:       "Your license for PACT is expiring in #{notify_days} days.")

      message.deliver!
    end
  end

  def self.check_license_expiring(licensee_id,
                                  notify_at = [ 45, 10 ],
                                  cc_list   = [
                                                 'paul@airworthinesscert.com',
                                                 'info@airworthinesscert.com'
                                              ])
    licensee = self.new

    licensee.license_expiring(licensee_id, notify_at, cc_list)
  end

  def license_expired(licensee_id,
                      notify_at = [ 1, 7, 14 ],
                      cc_list   = [
                                     'paul@airworthinesscert.com',
                                     'info@airworthinesscert.com'
                                  ])
    if licensee_id.kind_of?(String)
      @licensee   = Licensee.find_by(identifier: licensee_id)
    else
      @licensee   = Licensee.find_by(id: licensee_id)
    end

    return unless @licensee.present?

    to_list       = @licensee.contact_emails
    today         = Date.today

    return unless notify_at.present? && to_list.present? && @licensee.renewal_date

    notify_at     = notify_at.split(',') if notify_at.kind_of?(String)

    notify_at.each do |at|

      notify_days = at.to_i
      @days       = (today - @licensee.renewal_date).to_i

      next unless @days == notify_days

      message     = mail(template_path: 'licensee_mailer',
                         template_name: 'license_expired',
                         to:            to_list,
                         cc:            cc_list,
                         subject:       "Your license for PACT has expired.")

      message.deliver!
    end
  end

  def self.check_license_expired(licensee_id,
                                 notify_at = [ 1, 7, 14 ],
                                 cc_list   = [
                                                'paul@airworthinesscert.com',
                                                'info@airworthinesscert.com'
                                             ])
    licensee = self.new

    licensee.license_expired(licensee_id, notify_at, cc_list)
  end
end
