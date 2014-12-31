module Hurley
  class Test
    def initialize
      @handlers = []
    end

    def get(url)
      handle(:get, url, &Proc.new)
    end

    def put(url)
      handle(:put, url, &Proc.new)
    end

    def post(url)
      handle(:post, url, &Proc.new)
    end

    def delete(url)
      handle(:delete, url, &Proc.new)
    end

    def handle(verb, url)
      @handlers << Handler.new(Request.new(self, verb, Url.parse(url)), Proc.new)
    end

    def call(request)
      handler = @handlers.detect { |h| h.matches?(request) } ||
        self.class.method(:not_found)
      handler.call(request)
    end

    def all_run?
      @handlers.all?(&:run?)
    end

    class Handler < Struct.new(:request, :callback)
      def call(request)
        @run = true
        status, header, body = callback.call(request)
        Response.new(request, status, Header.new(header), body)
      end

      def matches?(request)
        self.request.verb == request.verb &&
          self.request.url.parent_of?(request.url)
      end

      def run?
        !!@run
      end
    end

    def self.not_found(request)
      Response.new(request, 404, Header.new, "no test handler")
    end
  end
end