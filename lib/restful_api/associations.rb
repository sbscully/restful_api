require 'active_support/inflector'
require 'active_support/core_ext/hash'

module RestfulApi
  module Associations
    def self.included(base)
      base.class_eval do
        alias_method :read_instance_without_associations, :read_instance
        alias_method :read_instance, :read_instance_with_associations

        alias_method :read_collection_without_associations, :read_collection
        alias_method :read_collection, :read_collection_with_associations
      end
    end

    def read_instance_with_associations(id, options={})
      instance = read_instance_without_associations(id, options)

      if options[:include]
        instance.merge(associations(get_instance(id), options[:include]))
      else
        instance
      end
    end

    def read_collection_with_associations(collection, options={})
      if options
        collection.map do |instance|
          read_instance(instance.id, options)
        end
      else
        read_collection_without_associations(collection)
      end
    end

    private

    def associations(instance, associations)
      associations = [associations] if associations.is_a? Symbol

      associations.map! do |association|
        if association.is_a? Hash
          name = association.keys.first
          options = association.values.first
          [name.to_s, read_association(instance, name, options)]
        else
          [association.to_s, read_association(instance, association)]
        end
      end
      Hash[associations]
    end

    def read_association(instance, association, options={})
      model = instance.send(association)

      if model.is_a? Array
        association_restful_api(association).read_collection(model, options)
      else
        association_restful_api(association).read_instance(model.id, options)
      end
    end

    def association_restful_api(association)
      self.class.new(association.to_s.classify.constantize)
    end
  end
end

class RestfulApi::Base
  include RestfulApi::Associations
end