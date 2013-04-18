require_relative '../restful_api'

module Sinatra
  module RestfulApi
    def restful_api(name)
      helpers do
        define_method("#{name}_api") do
          instance_variable_get("@#{name}_api") ||
            instance_variable_set("@#{name}_api", restful_api_for(name))
        end

        def restful_api_for(name)
          klass = name.to_s.singularize.classify.constantize
          settings.restful_api_adapter.new(klass).tap do |adapter|
            restful_json_api_setup(adapter)
          end
        end

        def restful_json_api_setup(adapter)
          json = ::RestfulApi::Json
          json.include_root_in_json = setting_or_default(:include_root_in_json, false)
          adapter.extend json
        end

        def setting_or_default(setting, default)
          settings.respond_to?(setting) ? settings.send(setting) : default
        end
      end

      post "/api/v1/#{name}" do
        send("#{name}_api").create(request.body.read)
      end

      get "/api/v1/#{name}/:id" do
        send("#{name}_api").read(params[:id], include: params[:include])
      end

      get "/api/v1/#{name}" do
        send("#{name}_api").read(params[:where] || :all, include: params[:include])
      end

      put "/api/v1/#{name}/:id" do
        send("#{name}_api").update(params[:id], request.body.read)
      end

      delete "/api/v1/#{name}/:id" do
        send("#{name}_api").destroy(params[:id])
      end
    end
  end

  register RestfulApi
end
