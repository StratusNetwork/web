module ApiPublic
  class ApiPublicController < CommonController
    include JsonController
    include ParamsHelper

    PROTO_HEADER = 'X-OCN-Version'

    around_filter :set_current_user
    after_filter :clear_cache
    respond_to :json

    def clear_cache
      Cache::RequestManager.clear_request_cache
    end

    def index
      respond({:status => true})
    end

    protected

    def set_current_user
      User.with_current(User.console_user) { yield }
    end

    rescue_from Mongoid::Errors::DocumentNotFound do |ex|
      render_error(404, "#{ex.klass.name} not found matching #{ex.params.inspect}")
    end
  end
end

