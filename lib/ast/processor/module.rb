module AST
  class Processor
    # This is used for inclusion in a class.  This is included in the
    # processor class by default, so by default anything that
    # subclasses the processor will also include this module.  The
    # reason for having the behavior in a module like this is to allow
    # a public class (or module) to include this behavior.  It also
    # promotes the "composition over inheritance" paradaigm.
    module Module
      # Dispatches `node`. If a node has type `:foo`, then a handler named
      # `on_foo` is invoked with one argument, the `node`; if there isn't
      # such a handler, {#handler_missing} is invoked with the same argument.
      #
      # If the handler returns `nil`, `node` is returned; otherwise, the return
      # value of the handler is passed along.
      #
      # @param  [AST::Node, nil] node
      # @return [AST::Node, nil]
      def process(node)
        return if node.nil?

        node = node.to_ast

        # Invoke a specific handler
        on_handler = :"on_#{node.type}"
        if respond_to? on_handler
          new_node = send on_handler, node
        else
          new_node = handler_missing(node)
        end

        node = new_node if new_node

        node
      end

      # {#process}es each node from `nodes` and returns an array of results.
      #
      # @param  [Array<AST::Node>] nodes
      # @return [Array<AST::Node>]
      def process_all(nodes)
        nodes.to_a.map do |node|
          process node
        end
      end

      # Default handler. Does nothing.
      #
      # @param  [AST::Node] node
      # @return [AST::Node, nil]
      def handler_missing(node)
      end
    end
  end
end
