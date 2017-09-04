module DeepCover
  class Node < Parser::AST::Node
  end
end

require_relative 'node/cover_entry'
require_relative 'node/cover_entry_and_exit'
require_relative_dir 'node'

module DeepCover
  # Base class to handle covered nodes.
  class Node < Parser::AST::Node
    attr_reader :context, :nb

    ### High level API for coverage purposes

    # Returns an array of character numbers (in the original buffer) that
    # pertain exclusively to this node (and thus not to any children).
    def proper_range
      location.expression.to_a - children.flat_map{|n| n.respond_to?(:location) && n.location && n.location.expression.to_a }
    end

    # Returns true iff it is executable. Keywords like `end` are not executable, but literals like `42` are executable.
    def executable?
      true
    end

    # Returns true iff it is executable and if was successfully executed
    def was_executed?
      false
    end

    # Returns the number of times it was executed (completely or not)
    def runs
      0
    end

    ### Public API

    # Returns a subclass or itself, according to type
    def self.factory(type)
      class_name = type.capitalize
      const_defined?(class_name) ? const_get(class_name) : self
    end

    # Code to add before the node for covering purposes (or `nil`)
    def prefix
    end

    # Code to add after the node for covering purposes (or `nil`)
    def suffix
    end

    # Returns true iff it changed the usual control flow (e.g. anything that raises, return, ...)
    # TODO: may not be that useful, e.g. `next`...
    def changed_control_flow?
      children.any? do |child|
        child.is_a?(Node) && child.changed_control_flow?
      end
    end

    # Protected
    def assign_properties(properties = {})
      @context = properties.fetch(:context)
      @nb = properties.fetch(:nb)
      super
    end
  end
end
