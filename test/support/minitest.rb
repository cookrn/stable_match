module MiniTest
  class Unit
    class TestCase
      alias_method '__assert__' , 'assert'

      def assert( *args , &block )
        if args.size == 1 and args.first.is_a?(Hash)
          options  = args.first
          expected = getopt(:expected, options){ missing }
          actual   = getopt(:actual, options){ missing }
          if expected == missing and actual == missing
            actual , expected , *_ = options.to_a.flatten
          end
          expected = expected.call() if expected.respond_to?(:call)
          actual   = actual.call() if actual.respond_to?(:call)
          assert_equal expected , actual
        end

        if block
          label   = "assert(#{ args.join(' ') })"
          result  = nil
          raised  = false
          result  = begin
                      block.call
                    rescue Object => e
                      raised = e
                      false
                    end
          __assert__ !raised , ( raised.message rescue label )
          __assert__ result  , label
          result
        else
          result = args.shift
          label  = "assert(#{ args.join(' ') })"
          __assert__ result , label
          result
        end
      end
    end
  end
end
