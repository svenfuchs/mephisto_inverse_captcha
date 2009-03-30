require 'inverse_captcha.rb'

# load modified commentform tag: delayed to happen after config/initializers/mephisto.init.rb
config.to_prepare do
  ActionController::Dispatcher.class_eval do
    # Mephisto patches #cleanup_application_with_plugins to run this *after*
    # every request, even in production
    class << self
      unless method_defined? :register_liquid_tags_with_inverse_captcha
        def register_liquid_tags_with_inverse_captcha
          register_liquid_tags_without_inverse_captcha
          Liquid::Template.register_tag "commentform", InverseCaptcha::CommentForm
        end
        alias_method_chain :register_liquid_tags, :inverse_captcha 
      end
    end
  end  
  # register tag for first time request
  Liquid::Template.register_tag "commentform", InverseCaptcha::CommentForm
end