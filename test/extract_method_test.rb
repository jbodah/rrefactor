require "test_helper"

describe Rrefactor::ExtractMethod do
  def given(src)
    @given = src
  end

  def extract_method(method_name, lines)
    @out = Rrefactor.extract_method(src: @given, range: lines, method_name: method_name)
  end

  def expect(exp)
    assert_equal exp.rstrip, @out, "Expected:\n\n#{exp.rstrip}\n\nGot\n\n#{@out}"
  end

  describe 'no local variables' do
    it 'works' do
      given <<~'EOF'
        def print_owing
          outstanding = 0.0
          # print banner
          puts("*************************")
          puts("***** Customer Owes *****")
          puts("*************************")
          # calculate outstanding
          @orders.each do |order|
            outstanding += order.amount
          end
          # print details
          puts("name: #{@name}")
          puts("amount: #{outstanding}")
        end
      EOF

      extract_method(:print_banner, [3, 6])

      expect <<~'EOF'
        def print_owing
          outstanding = 0.0
          print_banner
          @orders.each do |order|
            outstanding += order.amount
          end
          puts("name: #{@name}")
          puts("amount: #{outstanding}")
        end
        def print_banner
          puts("*************************")
          puts("***** Customer Owes *****")
          puts("*************************")
        end
      EOF
    end
  end

  describe 'instance variables' do
    it 'works' do
      given <<~'EOF'
        def print_owing
          print_banner
          puts("name: #{@name}")
        end
      EOF

      extract_method(:print_details, [3, 3])

      expect <<~'EOF'
        def print_owing
          print_banner
          print_details
        end
        def print_details
          puts("name: #{@name}")
        end
      EOF
    end
  end

  describe 'ast processing' do
    include AST::Sexp

    it 'processes the AST' do
      src = <<~'EOF'
      def print_owing
        print_banner
        puts("name: #{@name}")
      end
      EOF

      exp = <<~'EOF'
      def print_owing
        print_banner
        print_details
      end
      def print_details
        puts("name: #{@name}")
      end
      EOF

      src_ast = parse(src)
      exp_ast = parse(exp)
      actual = Rrefactor::ExtractMethod.new(src: src, range: [3, 3], method_name: :print_details).process(src_ast)
      assert_equal exp_ast, actual
    end
  end

  def parse(src)
    Parser::CurrentRuby.parse(src)
  end
end
