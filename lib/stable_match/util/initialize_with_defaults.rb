module StableMatch
  module Util
    module InitializeWithDefaults
      def self.included( klass )
        klass.extend ClassMethods
      end

      module ClassMethods
        def new( *args , &block )
          object = allocate

          object.initialize_defaults!

          object.send \
            :initialize,
            *args,
            &block

          object
        end
      end

      def initialize_defaults!
      end
    end
  end
end
