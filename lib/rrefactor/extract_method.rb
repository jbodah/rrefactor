require "rrefactor/node_builder"

module Rrefactor
  class ExtractMethod
    include AST::Processor::Mixin

    def initialize(opts)
      @opts = opts
    end

    def on_def(node)
      new_def, extracted = extract_nodes(node)

      if extracted.size > 1
        extracted = s(:begin, *extracted)
      else
        extracted = extracted.first
      end

      s(:begin,
        new_def,
        s(:def, @opts[:method_name],
          s(:args),
          extracted))
    end

    def s(type, *children)
      Parser::AST::Node.new(type, children)
    end

    def extract_nodes(node)
      main = extract_nodes2(node)
      [main, @extracted_nodes]
    end

    def extract_nodes2(node)
      if reject_node?(node)
        if defined?(@extracted_nodes)
          @extracted_nodes << node
          return nil
        else
          @extracted_nodes ||= []
          @extracted_nodes << node
          return s(:send, nil, @opts[:method_name])
        end
      end

      new_children = node.children.reduce([]) do |acc, child|
        if child.is_a?(Parser::AST::Node)
          result = extract_nodes2(child)
          acc << result if result
          acc
        else
          acc << child
        end
      end

      if node.type == :begin && new_children.size == 1
        new_children.first
      else
        Parser::AST::Node.new(node.type, new_children)
      end
    end

    def reject_node?(node)
      node.loc.line >= @opts[:range][0] && node.loc.line <= @opts[:range][1]
    rescue NoMethodError
      false
    end
  end
end
