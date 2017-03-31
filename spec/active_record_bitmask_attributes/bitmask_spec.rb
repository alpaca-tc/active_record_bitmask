RSpec.describe ActiveRecordBitmaskAttributes::Bitmask do
  describe 'InstanceMethods' do
    let(:instance) { described_class.new(value, mappings) }

    let(:mappings) { ActiveRecordBitmaskAttributes::Mappings.new(attribute, options) }
    let(:attribute) { :attribute }
    let(:options) do
      {
        as: [:a, :b, :c, :d, :e, :f, :g]
      }
    end

    describe '#bitmask' do
      subject { instance.bitmask }

      context 'value is nil' do
        let(:value) { nil }
        it { is_expected.to be_nil }
      end

      context 'value is 0' do
        let(:value) { 0 }
        it { is_expected.to be_nil }
      end

      context 'value is 1' do
        let(:value) { 1 }
        it { is_expected.to eq(1) }
      end

      context 'value is 2' do
        let(:value) { 2 }
        it { is_expected.to eq(2) }
      end

      context 'value is 127' do
        let(:value) { 127 }
        it { is_expected.to eq(127) }
      end

      context 'value is 128' do
        let(:value) { 128 }
        it { is_expected.to be_nil }
      end
    end

    describe '#==' do
      subject { instance }

      context 'value is nil' do
        let(:value) { nil }
        it { is_expected.to eq([]) }
      end

      context 'value is 0' do
        let(:value) { 0 }
        it { is_expected.to eq([]) }
      end

      context 'value is 1' do
        let(:value) { 1 }
        it { is_expected.to eq([:a]) }
      end

      context 'value is 2' do
        let(:value) { 2 }
        it { is_expected.to eq([:b]) }
      end

      context 'value is 127' do
        let(:value) { 127 }
        it { is_expected.to eq(options[:as]) }
      end

      context 'value is 128' do
        let(:value) { 128 }
        it { is_expected.to eq([]) }
      end
    end
  end
end
