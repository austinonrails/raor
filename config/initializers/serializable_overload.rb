module Devise
  module Models
    # This module redefine to_xml and serializable_hash in models for more
    # secure defaults. By default, it removes from the serializable model
    # all attributes that are *not* accessible. You can remove this default
    # by using :force_except and passing a new list of attributes you want
    # to exempt. All attributes given to :except will simply add names to
    # exempt to Devise internal list.
    module Serializable
      # TODO: to_xml does not call serializable_hash. Hopefully someone will fix this in AR.
      %w(to_xml serializable_hash).each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__
          def #{method}(options=nil)
            options ||= {}
            if options.key?(:force_except)
              options[:except] = options.delete(:force_except)
              super(options)
            elsif self.class.blacklist_keys?
              except = Array(options[:except])
              super(options.merge(:except => except + (self.class.blacklist_keys - self.send(:mass_assignment_authorizer).to_a)))
            else
              super
            end
          end
        RUBY
      end
    end
  end
end    