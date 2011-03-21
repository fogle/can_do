module CanDo
  class PermissionError < Exception
    def initialize(reason, debug_info = nil)
      super(reason)
      @debug_info = debug_info
    end
  end
end