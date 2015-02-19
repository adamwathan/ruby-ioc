class Container
  def initialize
    @items = {}
    @shared_keys = []
    @shared = {}
  end

  def [](key)
    make(key)
  end

  def []=(key, block)
    bind(key, &block)
  end

  def share(key, &block)
    @shared_keys << key
    bind(key, &block)
  end

  def bind(key, &block)
    @items[key] = block
  end

  def make(key)
    if shared?(key)
      item = get_shared(key) || share_new(key)
    else
      item = make_new(key)
    end
  end

  private
    def get_shared(key)
      @shared[key]
    end

    def share_new(key)
      item = store_shared(key, make_new(key))
    end

    def store_shared(key, item)
      @shared[key] = item
    end

    def make_new(key)
      if has_key?(key)
        @items[key].call(self)
      elsif key.instance_of?(Class)
        resolve_class(key)
      end
    end

    def resolve_class(key)
      args = []
      key.instance_method(:initialize).parameters.map(&:last).each do |arg|
        args << make(arg)
      end
      key.new(*args)
    end

    def has_key?(key)
      @items.has_key?(key)
    end

    def shared?(key)
      @shared_keys.include?(key)
    end
end

