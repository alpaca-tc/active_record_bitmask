RSpec.describe ActiveRecordBitmaskAttributes::BitmaskAccessor do
  describe 'ClassMethods' do
    describe '.bitmask' do
      context 'without :as option' do
        subject { -> { with_bitmask(Variation, :bitmask) {} } }
        it { is_expected.to raise_error(ArgumentError) }
      end

      context 'with :as option' do
        it 'builds mappings' do
          expect(Variation._bitmask_mappings).to_not be_key(:bitmask)

          with_bitmask(Variation, :bitmask, as: [:a]) do
            expect(Variation._bitmask_mappings).to be_key(:bitmask)
          end
        end

        context 'sub class' do
          it 'does not overwrite bitmask' do
            with_bitmask(Variation, :bitmask, as: [:a]) do
              expect { with_bitmask(SubVariation, :bitmask, as: [:b]) {} }.to raise_error(ArgumentError)
              expect { with_bitmask(SubVariation, :id, as: [:b]) {} }.to_not raise_error(ArgumentError)
            end
          end
        end
      end

      skip 'defines methods with ActiveRecordBitmaskAttributes::Definition'
    end
  end
end
