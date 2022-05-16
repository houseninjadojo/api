# frozen_string_literal: true

require 'spec_helper'

require_relative '../../app/lib/wait'

RSpec.describe 'Wait' do
  context 'class methods' do
    subject { Wait }

    it { is_expected.to respond_to(:while, :until) }
  end

  describe '.until' do
    context 'when the condition is true right away' do
      it 'returns right away, without sleeping' do
        expect_any_instance_of(Wait).to_not receive(:sleep)
        Wait.until { |c, t| c == 0 }
      end
    end

    context 'when the condition is false initially' do
      it 'loops until the condition is true' do
        expect_any_instance_of(Wait).to receive(:sleep).exactly(2).times
        Wait.until { |c, t| c >= 2 }
      end

      it 'keeps track of the time spent looping' do
        Wait.until { |c, t| (@time = t) > 0.5 }
        expect(@time).to be_a(Float)
      end
    end

    context 'with limit' do
      context 'with the condition is positive before the limit is exceeded' do
        subject { Wait.until(limit: 5) { |c, t| c >= 4 && c } }

        it 'returns the last value' do
          expect(subject).to eq 4
        end

        it 'does not throw an exception' do
          expect { subject }.to_not raise_error
        end
      end

      context 'when the limit is reached first' do
        subject { Wait.until(limit: 5) { |c, t| c >= 8 && c } }

        it 'raises a Limit error' do
          expect { subject }.to raise_error(Wait::LimitError, /limit has been exceeded/)
        end

        context 'with a custom message' do
          subject { Wait.until(limit: 5, msg: 'Ruh-roh!') { |c, t| c >= 8 && c } }

          it 'raises the error with the custom message' do
            expect { subject }.to raise_error(Wait::LimitError, /Ruh-roh!/)
          end
        end
      end
    end

    context 'with max_time' do
      context 'when the condition is true before the max_time is reached' do
        subject { Wait.until(max_time: 4.0) { |c, t| (@time = t) > 2.0 && t } }

        it 'returns the last value' do
          expect(subject).to eq @time
        end
      end

      context 'when the max_time is reached before the condition is true' do
        subject { Wait.until(max_time: 1.0) { |c, t| (@time = t) > 2.0 } }

        it 'raises a Timeout error' do
          expect { subject }.to raise_error(Wait::TimeoutError, /Wait time has been exceeded/)
        end
      end

      context 'with a custom message' do
        subject { Wait.until(max_time: 1.0, msg: 'Ruh-roh!') { |c, t| t > 2.0 } }

        it 'raises the error with the custom message' do
          expect { subject }.to raise_error(Wait::TimeoutError, /Ruh-roh!/)
        end
      end
    end

    context 'with both limit and max_time' do
      context 'when the condition is true first' do
        subject { Wait.until(max_time: 10.0, limit: 10) { |c, t| c > 5 && t < 1.0 && c } }

        it 'returns the last result' do
          expect(subject).to eq 6
        end
      end

      context 'when the limit is exceeded first' do
        subject { Wait.until(max_time: 10.0, limit: 10) { |c, t| c > 100 } }

        it 'raises the Limit error' do
          expect { subject }.to raise_error(Wait::LimitError)
        end
      end

      context 'when the max_time is exceeded first' do
        subject { Wait.until(max_time: 1.0, limit: 10) { |c, t| t > 2.0 } }

        it 'raises the Timeout error' do
          expect { subject }.to raise_error(Wait::TimeoutError)
        end
      end
    end
  end

  describe '.while' do
    subject { Wait.while(**args) { condition } }

    # TODO

  end
end
