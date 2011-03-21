module CanDo
  class Dsl
    NIL_REASON = "Object of query does not exist."
    def noun(object)
      noun = object.class unless object.class == Class || object.class == String
      noun || object
    end

    def can?(action, object)
      can = internal_reason(action, noun(object), object).nil?
      yield if can && block_given?
      can
    end
  
    def reason(action, object)
      internal_reason(action, noun(object), object)
    end
  
    def internal_reason(action, noun, object)
      return NIL_REASON if object.nil?
      rules = @can_hash[action][noun]
      rules.each do |rule|
        return rule.reason unless rule.call(object, noun)
      end
      nil
    end
    
    def can(action, noun, &block)
      @rules = []
      yield
      @can_hash[action] ||= {}
      @can_hash[action][noun] = @rules
    end
  
    def rule(reason=nil, &block)
      @rules << Rule.new(reason, &block)
    end
  
    def cascade(action, &block)
      @rules << Cascade.new(action, self, &block)
    end
  
    def initialize &block
      @can_hash = {}
      instance_eval &block
    end
  
    class Rule
      attr_reader :reason
    
      def initialize(reason, &block)
        @reason = reason || "Unknown Reason"
        @block = block
      end
    
      def call(object, noun)
        @block.call(object)
      end
    end
  
    class Cascade
      def initialize(action, ability, &block)
        @action = action
        @ability = ability
        @transformation = block
      end

      def reason
        @reason
      end
    
      def call(object, noun)
        @reason = nil
        object = @transformation.call(object) if @transformation
        noun = @ability.noun(object) if @transformation
        @reason = @ability.internal_reason(@action, noun, object)
        @reason.nil?
      end
    end
  end
end