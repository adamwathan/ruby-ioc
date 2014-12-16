require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require_relative 'container'

describe Container do
  it "can resolve an object with no dependencies" do
    c = Container.new
    c.bind(:foobar) { 'foobar' }
    f = c.make :foobar
    f.must_equal('foobar')
  end

  it "can resolve an object that depends on another binding" do
    c = Container.new
    c.bind(:foo) { 'foo' }
    c.bind(:bar) { |container| container.make(:foo) + 'bar' }
    f = c.make(:bar)
    f.must_equal('foobar')
  end

  it "can resolve objects using array syntax" do
    c = Container.new
    c.bind(:foobar) { 'foobar' }
    f = c[:foobar]
    f.must_equal('foobar')
  end

  it "can bind objects using array syntax" do
    c = Container.new
    c[:foobar] = proc { 'foobar' }
    f = c[:foobar]
    f.must_equal('foobar')
  end

  it "can share a single instance of a dependency" do
    c = Container.new
    c.share(:shared) { Object.new }
    c[:shared].must_be_same_as c[:shared]
  end

  it "returns unique instances for bindings that aren't shared" do
    c = Container.new
    c.bind(:unique) { Object.new }
    c[:unique].wont_be_same_as c[:unique]
  end

  it "can instantiate arbitrary classes by class name" do
    c = Container.new
    c[Foobar].must_be_instance_of Foobar
  end

  it "can resolve constructor dependencies of an arbitrary class" do
    c = Container.new
    c[:foobar] = proc { 'example_string' }
    c[Baz].foobar.must_equal 'example_string'
  end
end

class Foobar
end

class Baz
  attr_reader :foobar
  def initialize(foobar)
    @foobar = foobar
  end
end
