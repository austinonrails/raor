module CanCan
  class ControllerResource
    protected
    def find_resource
      if @options[:singleton] && parent_resource.respond_to?(name)
        parent_resource.send(name)
      else
        @options[:find_by] ? resource_base.send("find_by_#{@options[:find_by]}!", id_param, :as => @options[:as]) : resource_base.find(id_param)
      end
    end

    def resource_base
      @options[:as] = @controller.can?(:manage, resource_class) ? :default : :admin
      if @options[:through]
        if parent_resource
          @options[:singleton] ? resource_class : parent_resource.send(@options[:through_association] || name.to_s.pluralize)
        elsif @options[:shallow]
          resource_class
        else
          raise AccessDenied.new(nil, authorization_action, resource_class) # maybe this should be a record not found error instead?
        end
      else
        resource_class
      end
    end
  end
end
