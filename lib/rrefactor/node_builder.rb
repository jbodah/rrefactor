module Rrefactor
  class NodeBuilder
    attr_accessor :type, :children

    def initialize
      @children = []
    end

    def build
      Parser::AST::Node.new(type, children)
    end

    def <<(other)
      @children << other
    end
  end
end
