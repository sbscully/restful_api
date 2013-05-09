module RestfulApi
  class NotFoundError < StandardError; end
  class InvalidAttributesError < StandardError; end

  class Base
    attr_reader :resource

    def initialize(resource)
      @resource = resource
    end

    def create(attrs)
    end

    def build
      read_instance(build_instance)
    end

    def read(id, options={})
      if id.is_a? Hash
        read_where(id, options)
      elsif id == :all
        read_all(options)
      else
        read_instance(get_instance(id), options)
      end
    end

    def read_collection(collection, options={})
      collection.map! { |instance| read_instance(instance) }
    end

    def read_instance(instance, options={})
      raise RestfulApi::NotFoundError, 'Resource not found' unless instance.present?
      to_hash(instance)
    end

    def update(id, attrs)
    end

    def destroy(id)
    end

    private

    def read_all(options={})
      read_collection(get_all, options)
    end

    def read_where(conditions, options={})
      read_collection(get_where(conditions), options)
    end

    def get_instance(id)
      if id == :first
        get_first
      elsif id == :last
        get_last
      else
        get_id(id)
      end
    end

    def get_all
    end

    def get_first
    end

    def get_last
    end

    def get_id(id)
    end

    def to_hash(instance)
    end

  end
end