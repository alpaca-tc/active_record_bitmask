# frozen_string_literal: true

RSpec.describe ActiveRecordBitmask::Model do
  describe 'ClassMethods' do
    describe '.bitmask' do
      context 'without :as option' do
        subject { -> { with_bitmask(Variation, :bitmask) {} } }
        it { is_expected.to raise_error(ArgumentError) }
      end

      context 'with :as option' do
        it 'builds mappings' do
          with_bitmask(Variation, :bitmask, as: [:a]) do
            expect(Variation.bitmask_for(:bitmask)).to_not be_nil
          end
        end

        context 'sub class' do
          it 'inherits mappings' do
            with_bitmask(Variation, :bitmask, as: [:a]) do
              expect(SubVariation.bitmask_for(:bitmask)).to be_present
            end
          end

          it 'does not overwrite bitmask' do
            with_bitmask(Variation, :bitmask, as: [:a]) do
              expect { with_bitmask(SubVariation, :bitmask, as: [:b]) {} }.to raise_error(ArgumentError)
              expect { with_bitmask(SubVariation, :id, as: [:b]) {} }.to_not raise_error
            end
          end
        end
      end

      skip 'defines methods with ActiveRecordBitmask::Definition'
    end

    describe '.bitmask_for' do
      subject { Variation.bitmask_for(:bitmask) }

      around do |example|
        with_bitmask(Variation, :bitmask, as: [:a]) { example.run }
      end

      it { is_expected.to be_a(ActiveRecordBitmask::Mappings) }
    end
  end
end
