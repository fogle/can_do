require 'spec_helper'

describe CanDo::Dsl do
  before do
    @dsl = CanDo::Dsl.new
    @dsl.instance_eval do
      can :be_numeric, Symbol do
        rule("couldn't convert to a number") {|symbol, noun| symbol.to_s.gsub('"', '').to_i.to_s == symbol.to_s.gsub('"', '')}
      end

      can :be_odd, Fixnum do
        rule("wasn't odd") {|number, noun| number.odd?}
      end
  
      can :be_odd, Symbol do
        cascade(:be_numeric)
        cascade(:be_odd) {|symbol| symbol.to_s.gsub('"', '').to_i}
      end
    end
  end

  it 'returns non-nil when passed a nil noun' do
    @dsl.can?(:be_numeric, nil).should == false
    @dsl.reason(:be_numeric, nil).should == CanDo::Dsl::NIL_REASON
  end

  it 'handles simple rules like :be_numeric, Symbol' do
    @dsl.can?(:be_numeric, :"3").should == true
    @dsl.can?(:be_numeric, :"3ish").should == false


    @dsl.reason(:be_numeric, :"3").should be_nil
    @dsl.reason(:be_numeric, :"3ish").should == "couldn't convert to a number"


  end

  it 'handles simple rules like :be_odd, Fixnum' do
    @dsl.can?(:be_odd, 3).should == true
    @dsl.can?(:be_odd, 2).should == false
    @dsl.reason(:be_odd, 3).should be_nil
    @dsl.reason(:be_odd, 2).should == "wasn't odd"
  end
  
  it 'supports cascading rules' do
    @dsl.can?(:be_odd, :"3ish").should == false
    @dsl.reason(:be_odd, :"3ish").should == "couldn't convert to a number"

    @dsl.can?(:be_odd, :"3").should == true
    @dsl.reason(:be_odd, :"3").should be_nil
    
    @dsl.can?(:be_odd, :"2").should == false
    @dsl.reason(:be_odd, :"2").should == "wasn't odd"
  end
end