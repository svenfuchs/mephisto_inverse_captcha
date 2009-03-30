module InverseCaptcha
  def self.codename(name)
    name.to_s.crypt('somesalt').downcase.gsub(/[^a-z]*/, '')
  end  

  class Param < Struct.new(:name, :scope) 
    def initialize(name, scope)
      self.name = name.to_s
      self.scope = scope.is_a?(Array) ? scope : [scope]
    end
    def codename
      @codename ||= InverseCaptcha::codename(self.name)
    end 
  end

  module MephistoController
    
    include_into 'MephistoController'

    def self.included(base)
      base.extend ClassMethods
      base.cattr_accessor :sneaky_params
      base.sneaky_params = []
      base.send :sneak, :author_email, :comment
      base.send :before_filter, :unsneak, :kick_stupid_bots
    end
    
    module ClassMethods
      def sneak(name, scope)
        sneaky_params << InverseCaptcha::Param.new(name, scope)
      end
    end
  
    def unsneak
      sneaky_params.each do |param| 
        source = params
        param.scope.each do |scope|
          source = source[scope] unless source.blank?
        end
        return if source.blank?
        unless source[param.name].blank?
          (@suspicious_params ||= []) << param
        end
        source[param.name] = source[param.codename]
        source.delete(param.codename)
        logger.info "unsneaked sneaky param #{param.name}"
      end
    end 
    
    def kick_stupid_bots      
      unless @suspicious_params.blank?
        @suspicious_params = []
        logger.info 'caught a superstupid bot while he was trying to dump garbage and kicked him!'
        set_cache_root
        path = Mephisto::Dispatcher.run(site, params[:path].dup)
        article = site.articles.find_by_permalink(path[2])
        redirect_to site.permalink_for(article)
      end
    end
  end
end
