require "rrefactor/version"
require "parser/current"
require "ast"
require "unparser"
require "rrefactor/extract_method"

class Parser::AST::Node
  def child_nodes
    children.select { |c| c.is_a?(self.class) }
  end
end

module Rrefactor
  def self.extract_method(opts)
    ast = Parser::CurrentRuby.parse(opts[:src])
    new_ast = ExtractMethod.new(opts).process(ast)
    Unparser.unparse(new_ast)
  end
end
