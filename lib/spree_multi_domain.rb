require 'spree_core'
require 'spree_multi_domain_hooks'
require 'spree_multi_domain/engine'


# Make it possible to add to existing resource controller hooks with '<<' even when there's no hook of a given type defined yet.
# e.g. create.before << :assign_to_store
ResourceController::Accessors.module_eval do
  private
  def block_accessor(*accessors)
    accessors.each do |block_accessor|
      class_eval <<-"end_eval", __FILE__, __LINE__

        def #{block_accessor}(*args, &block)
          @#{block_accessor} ||= []
          unless args.empty? && block.nil?
            args.push block if block_given?
            @#{block_accessor} = [args].flatten
          end
          @#{block_accessor}
        end

      end_eval
    end
  end
end


module ActionView::Layouts

  def find_layout_with_multi_store(layout)
    if respond_to?(:current_store) && current_store && !controller.is_a?(Admin::BaseController)
      layout.gsub!("layouts/", "layouts/#{current_store.code}/")
    end
    find_layout_without_multi_store(layout)
  end

  alias_method_chain :find_layout, :multi_store

end

