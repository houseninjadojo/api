# spec/lib/json_spec.rb
require 'rails_helper'

# require 'lib/core_ext/ruby/json/safe_parse'

require_relative '../../../../../lib/core_ext/ruby/json/safe_parse'

RSpec.describe JSON do
  context 'class methods' do
    subject { JSON }

    it { is_expected.to respond_to(:safe_parse) }
  end

  describe '.safe_parse' do
    it 'should return nil for invalid json' do
      JSON.safe_parse('not json').should be_nil
    end

    it 'should return a ruby hash for valid json' do
      JSON.safe_parse('{ "some": "json" }').should == { 'some' => 'json' }
    end
  end
end
