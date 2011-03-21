require 'can_do/dsl'

module CanDo
  def self.setup &block
    @active_dsl = CanDo::Dsl.new &block
  end
  
  def self.can?(verb, noun, &block)
    raise "you must first call setup" unless @active_dsl
    @active_dsl.can?(verb, noun, &block)
  end

  def self.reason(verb, noun)
    raise "you must first call setup" unless @active_dsl
    @active_dsl.reason(verb, noun)
  end
end

module ActionController
  class Base
    def can?(*args, &block)
      CanDo.can?(*args, &block)
    end
  end
end

module ActionView
  module Helpers
    def can?(*args, &block)
      CanDo.can?(*args, &block)
    end
  end
end