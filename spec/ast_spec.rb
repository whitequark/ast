require 'helper'

RSpec.describe AST::Node do
  extend AST::Sexp

  class MetaNode < AST::Node
    attr_reader :meta
  end

  class SubclassNode < AST::Node
    def initialize(*)
      super
      nil
    end
  end

  before do
    @node = AST::Node.new(:node, [ 0, 1 ])
    @metanode = MetaNode.new(:node, [ 0, 1 ], :meta => 'value')
    @subclass_node = SubclassNode.new(:node, [ 0, 1 ])
  end

  it 'should have accessors for type and children' do
    expect(@node.type).to eq :node
    expect(@node.children).to eq [0, 1]
  end

  it 'should set metadata' do
    expect(@metanode.meta).to eq 'value'
  end

  it 'should be frozen' do
    expect(@node.frozen?).to be true
    expect(@node.children.frozen?).to be true
  end

  it 'should return self when duping' do
    expect(@node.dup).to be @node
  end

  it 'should return self when cloning' do
    expect(@node.clone).to be @node
  end

  it 'should return an updated node, but only if needed' do
    expect(@node.updated()).to be @node
    expect(@node.updated(:node)).to be @node
    expect(@node.updated(nil, [0, 1])).to be @node

    updated = @node.updated(:other_node)
    expect(updated).to_not be @node
    expect(updated.type).to eq :other_node
    expect(updated.children).to eq @node.children

    expect(updated.frozen?).to eq true

    updated = @node.updated(nil, [1, 1])
    expect(updated).to_not be @node
    expect(updated.type).to eq @node.type
    expect(updated.children).to eq [1, 1]

    updated = @metanode.updated(nil, nil, :meta => 'other_value')
    expect(updated.meta).to eq 'other_value'
  end

  it 'returns updated node for subclasses that override constructor' do
    updated = @subclass_node.updated(nil, [2])
    expect(updated.type).to eq :node
    expect(updated.children).to eq [2]
  end

  it 'should format to_sexp correctly' do
    a = AST::Node.new(:a, [ :sym, [ 1, 2 ] ]).to_sexp
    expect(a).to eq '(a :sym [1, 2])'
    b = AST::Node.new(:a, [ :sym, @node ]).to_sexp
    expect(b).to eq "(a :sym\n  (node 0 1))"
    c = AST::Node.new(:a, [ :sym,
      AST::Node.new(:b, [ @node, @node ])
    ]).to_sexp
    expect(c).to eq "(a :sym\n  (b\n    (node 0 1)\n    (node 0 1)))"
  end

  it 'should format to_s correctly' do
    a = AST::Node.new(:a, [ :sym, [ 1, 2 ] ]).to_s
    expect(a).to eq '(a :sym [1, 2])'
    b = AST::Node.new(:a, [ :sym, @node ]).to_s
    expect(b).to eq "(a :sym\n  (node 0 1))"
    c = AST::Node.new(:a, [ :sym,
      AST::Node.new(:b, [ @node, @node ])
    ]).to_s
    expect(c).to eq "(a :sym\n  (b\n    (node 0 1)\n    (node 0 1)))"
  end

  it 'should format inspect correctly' do
    a = AST::Node.new(:a, [ :sym, [ 1, 2 ] ]).inspect
    expect(a).to eq "s(:a, :sym, [1, 2])"
    b = AST::Node.new(:a, [ :sym,
      AST::Node.new(:b, [ @node, @node ])
    ]).inspect
    expect(b).to eq "s(:a, :sym,\n  s(:b,\n    s(:node, 0, 1),\n    s(:node, 0, 1)))"
  end

  context do
    simple_node = AST::Node.new(:a, [ :sym, [ 1, 2 ] ])
    a = eval(simple_node.inspect)

    it 'should recreate inspect output' do
      expect(a).to eq simple_node
    end
  end

  context do
    complex_node =  s(:a ,  :sym,  s(:b, s(:node,  0,  1),  s(:node,  0,  1)))
    b = eval(complex_node.inspect)

    it 'should recreate inspect output' do
      expect(b).to eq complex_node
    end
  end

  it 'should return self in to_ast' do
    expect(@node.to_ast).to be @node
  end

  it 'should produce to_sexp_array correctly' do
    a = AST::Node.new(:a, [ :sym, [ 1, 2 ] ]).to_sexp_array
    expect(a).to eq [:a, :sym, [1, 2]]
    b = AST::Node.new(:a, [ :sym,
      AST::Node.new(:b, [ @node, @node ])
    ]).to_sexp_array
    expect(b).to eq [:a, :sym, [:b, [:node, 0, 1], [:node, 0, 1]]]
  end

  it 'should only use type and children to compute #hash' do
    expect(@node.hash).to eq([@node.type, @node.children, @node.class].hash)
  end

  it 'should only use type and children in #eql? comparisons' do
    # Not identical but equivalent
    expect(@node.eql?(AST::Node.new(:node, [0, 1]))).to eq true
    # Not identical and not equivalent
    expect(@node.eql?(AST::Node.new(:other, [0, 1]))).to eq false
    # Not identical and not equivalent because of differend class
    expect(@node.eql?(@metanode)).to eq false
  end

  it 'should only use type and children in #== comparisons' do
    expect(@node).to eq @node
    expect(@node).to eq @metanode
    expect(@node).to_not eq :foo

    mock_node = Object.new.tap do |obj|
      def obj.to_ast
        self
      end

      def obj.type
        :node
      end

      def obj.children
        [ 0, 1 ]
      end
    end
    expect(@node).to eq mock_node
  end

  context do
    node = s(:gasgn, :$foo, s(:integer, 1))
    var_name, value = *node
    expected = s(:integer, 1)

    it 'should allow to decompose nodes with a, b = *node' do
      expect(var_name).to eq :$foo
      expect(value).to eq expected
    end
  end

  context do
    node = s(:gasgn, :$foo)
    array = [s(:integer, 1)]
    expected = s(:gasgn, :$foo, s(:integer, 1))

    it 'should concatenate with arrays' do
      expect(node + array).to eq expected
    end
  end

  context do
    node = s(:array)
    a = s(:integer, 1)
    b = s(:string, "foo")
    expected = s(:array, s(:integer, 1), s(:string, "foo"))

    it 'should append elements' do
      expect(node << a << b).to eq expected
    end
  end

  begin
    eval <<-CODE
    context do
      bar = [ s(:bar, 1) ]
      baz = s(:baz, 2)
      value = s(:foo, *bar, baz)
      expected = s(:foo, s(:bar, 1), s(:baz, 2))

      it 'should not trigger a rubinius bug' do
        expect(value).to eq expected
      end
    end
    CODE
  rescue SyntaxError
    # Running on 1.8, ignore.
  end

  begin
    eval <<-CODE
    context do
      baz = s(:baz, s(:bar, 1), 2)

      it 'should be matchable' do
        r = case baz
        in [:baz, [:bar, val], Integer] then val
        else
          :no_match
        end
        expect(r).to eq 1
      end
    end
    CODE
  rescue SyntaxError
    # Running on < 2.7, ignore.
  end
end

describe AST::Processor do
  extend AST::Sexp

  def have_sexp(text)
    text = text.lines.map { |line| line.sub /^ +\|(.+)/, '\1' }.join.rstrip
    lambda { |ast| ast.to_sexp == text }
  end

  class MockProcessor < AST::Processor
    attr_reader :counts

    def initialize
      @counts = Hash.new(0)
    end

    def on_root(node)
      count_node(node)
      node.updated(nil, process_all(node.children))
    end
    alias on_body on_root

    def on_def(node)
      count_node(node)
      name, arglist, body = node.children
      node.updated(:def, [ name, process(arglist), process(body) ])
    end

    def handler_missing(node)
      count_node(node)
    end

    def count_node(node)
      @counts[node.type] += 1; nil
    end
  end

  before do
    @ast = AST::Node.new(:root, [
      AST::Node.new(:def, [ :func,
        AST::Node.new(:arglist, [ :foo, :bar ]),
        AST::Node.new(:body, [
          AST::Node.new(:invoke, [ :puts, "Hello world" ])
        ])
      ]),
      AST::Node.new(:invoke, [ :func ])
    ])

    @processor = MockProcessor.new
  end

  it 'should visit every node' do
    expect(@processor.process(@ast)).to eq @ast
    expect(@processor.counts).to eq({
      :root    => 1,
      :def     => 1,
      :arglist => 1,
      :body    => 1,
      :invoke  => 2,
    })
  end

  it 'should be able to replace inner nodes' do
    def @processor.on_arglist(node)
      node.updated(:new_fancy_arglist)
    end

    expect(have_sexp(<<-SEXP).call(@processor.process(@ast))).to be true
    |(root
    |  (def :func
    |    (new-fancy-arglist :foo :bar)
    |    (body
    |      (invoke :puts "Hello world")))
    |  (invoke :func))
    SEXP
  end

  context do
    a = s(:add,
      s(:integer, 1),
      s(:multiply,
        s(:integer, 2),
        s(:integer, 3)))
    it 'should build sexps' do
      expect(have_sexp(<<-SEXP).call(a)).to be true
      |(add
      |  (integer 1)
      |  (multiply
      |    (integer 2)
      |    (integer 3)))
      SEXP
    end
  end

  it 'should return nil if passed nil' do
    expect(@processor.process(nil)).to eq nil
  end

  it 'should refuse to process non-nodes' do
    expect { @processor.process([]) }.to raise_error NoMethodError, %r|to_ast|
  end

  context do
    value = s(:foo, s(:bar), s(:integer, 1))

    it 'should allow to visit nodes with process_all(node)' do
      @processor.process_all value
      expect(@processor.counts).to eq({
        :bar =>     1,
        :integer => 1,
      })
    end
  end
end
