module AST
  # This class includes {AST::Processor::Behavior}; however, it is
  # deprecated, since the module defines all of the behaviors that
  # the processor includes.  Any new libraries should use
  # {AST::Processor::Behavior} instead of subclassing this.
  #
  # @deprecated Use {AST::Processor::Behavior} instead.
  class Processor
    require 'ast/processor/behavior'
    include Behavior
  end
end
