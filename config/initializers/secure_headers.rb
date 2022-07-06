SecureHeaders::Configuration.default do |config|
  if Rails.env.production? 
    config.cookies = {
      secure: true, 
      httponly: true,
      samesite: {
        lax: true
      }
    }

    config.csp = SecureHeaders::OPT_OUT
    config.hsts = SecureHeaders::OPT_OUT
    config.x_content_type_options = "nosniff"
    config.x_xss_protection = "1; mode=block"
    config.x_download_options = "noopen"
    config.x_permitted_cross_domain_policies = "none"
    config.referrer_policy = %w(origin-when-cross-origin strict-origin-when-cross-origin)

  else
    config.csp = SecureHeaders::OPT_OUT
    config.hsts = SecureHeaders::OPT_OUT
    config.x_frame_options = SecureHeaders::OPT_OUT
    config.x_content_type_options = SecureHeaders::OPT_OUT
    config.x_xss_protection = SecureHeaders::OPT_OUT
    config.x_permitted_cross_domain_policies = SecureHeaders::OPT_OUT
  end
end