module DeepCover
  class Node
    class Splat < Node
      has_tracker :completion
      has_child receiver: Node

      def prefix
        "*["
      end

      def suffix
        "].tap{#{completion_tracker_source}}"
      end

      def flow_completion_count
        completion_tracker_hits
      end

      def execution_count
        last = children_nodes.last
        return last.flow_completion_count if last
        super
      end
    end

    class Kwsplat < Node
      has_tracker :completion
      has_child receiver: Node

      def prefix
        "**{"
      end

      def suffix
        "}.tap{#{completion_tracker_source}}"
      end

      def flow_completion_count
        completion_tracker_hits
      end

      def execution_count
        last = children_nodes.last
        return last.flow_completion_count if last
        super
      end
    end
  end
end