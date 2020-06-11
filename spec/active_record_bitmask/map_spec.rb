# frozen_string_literal: true

RSpec.describe ActiveRecordBitmask::Map do
  describe 'InstanceMethods' do
    let(:instance) { described_class.new(as) }

    let(:as) do
      %i[a b c d e f g]
    end

    describe '#each' do
      subject { instance.each }

      it do
        instance.each do |key, value|
          expect(as).to be_include(key)
          expect(value).to be_a(Integer)
        end
      end
    end

    describe '#keys' do
      subject { instance.keys }
      it { is_expected.to eq(as) }
    end

    describe '#values' do
      subject { instance.values }
      it { is_expected.to eq([1, 2, 4, 8, 16, 32, 64]) }
    end

    describe '#bitmask_to_attributes' do
      subject { instance.bitmask_to_attributes(value) }

      context 'with nil' do
        let(:value) { nil }
        it { is_expected.to eq([]) }
      end

      context 'with 0' do
        let(:value) { 0 }
        it { is_expected.to eq([]) }
      end

      context 'with 1' do
        let(:value) { 1 }
        it { is_expected.to eq([:a]) }
      end

      context 'with 2' do
        let(:value) { 2 }
        it { is_expected.to eq([:b]) }
      end

      context 'with 3' do
        let(:value) { 3 }
        it { is_expected.to eq(%i[a b]) }
      end

      context 'with 127' do
        let(:value) { 127 }
        it { is_expected.to eq(as) }
      end
    end

    describe '#attributes_to_bitmask' do
      subject { instance.attributes_to_bitmask(value) }

      context 'given []' do
        let(:value) { [] }
        it { is_expected.to eq(0) }
      end

      context 'given nil' do
        let(:value) { nil }
        it { is_expected.to eq(0) }
      end

      context 'given 0' do
        let(:value) { 0 }
        it { is_expected.to eq(0) }
      end

      context 'given ""' do
        let(:value) { '' }
        it { is_expected.to eq(0) }
      end

      context 'given "0"' do
        let(:value) { '0' }
        it { is_expected.to eq(0) }
      end

      context 'given [:a]' do
        let(:value) { [:a] }
        it { is_expected.to eq(1) }
      end

      context 'given [:b]' do
        let(:value) { [:b] }
        it { is_expected.to eq(2) }
      end

      context 'given [:a, :b]' do
        let(:value) { %i[a b] }
        it { is_expected.to eq(3) }
      end

      context 'given [:a, :b, :c, :d, :e, :f, :g]' do
        let(:value) { as }
        it { is_expected.to eq(127) }
      end
    end

    describe '#bitmask_combination' do
      subject { instance.bitmask_combination(value) }

      context 'given 0' do
        let(:value) { 0 }
        it { is_expected.to eq([0]) }
      end

      context 'given nil' do
        let(:value) { nil }
        it { is_expected.to eq([0]) }
      end

      context 'given 1' do
        let(:value) { 1 }

        it do
          is_expected.to eq(
            [
              1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25,
              27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49,
              51, 53, 55, 57, 59, 61, 63, 65, 67, 69, 71, 73,
              75, 77, 79, 81, 83, 85, 87, 89, 91, 93, 95, 97,
              99, 101, 103, 105, 107, 109, 111, 113, 115, 117,
              119, 121, 123, 125, 127
            ]
          )
        end
      end

      context 'given 2' do
        let(:value) { 2 }

        it do
          is_expected.to eq(
            [
              2, 3, 6, 7, 10, 11, 14, 15, 18, 19, 22, 23, 26,
              27, 30, 31, 34, 35, 38, 39, 42, 43, 46, 47, 50,
              51, 54, 55, 58, 59, 62, 63, 66, 67, 70, 71, 74,
              75, 78, 79, 82, 83, 86, 87, 90, 91, 94, 95, 98,
              99, 102, 103, 106, 107, 110, 111, 114, 115, 118,
              119, 122, 123, 126, 127
            ]
          )
        end
      end

      context 'given 127' do
        let(:value) { 127 }
        it { is_expected.to eq([127]) }
      end
    end

    describe '#all_combination' do
      subject { instance.all_combination }
      it { is_expected.to eq((1..127)) }
    end

    describe '#bitmask_or_attributes_to_bitmask' do
      subject { instance.bitmask_or_attributes_to_bitmask(value) }

      context 'given 0' do
        let(:value) { 0 }
        it { is_expected.to eq(0) }
      end

      context 'given 1' do
        let(:value) { 1 }
        it { is_expected.to eq(1) }
      end

      context 'given 2' do
        let(:value) { 2 }
        it { is_expected.to eq(2) }
      end

      context 'given 127' do
        let(:value) { 127 }
        it { is_expected.to eq(127) }
      end

      context 'given 128' do
        let(:value) { 128 }
        it { is_expected.to eq(0) }
      end

      context 'given []' do
        let(:value) { [] }
        it { is_expected.to eq(0) }
      end

      context 'given [:a]' do
        let(:value) { [:a] }
        it { is_expected.to eq(1) }
      end

      context 'given [:a, :b]' do
        let(:value) { %i[a b] }
        it { is_expected.to eq(3) }
      end

      context 'given [:a, :b, :c, :d, :e, :f, :g]' do
        let(:value) { as }
        it { is_expected.to eq(127) }
      end

      context 'with [1]' do
        let(:value) { [1] }
        it { is_expected.to eq(1) }
      end

      context 'with [3]' do
        let(:value) { [3] }
        it { is_expected.to eq(3) }
      end

      context 'with [1 3]' do
        let(:value) { [1, 3] }
        it { is_expected.to eq(3) }
      end

      context 'with [3 3]' do
        let(:value) { [3, 3] }
        it { is_expected.to eq(3) }
      end

      context 'given :a' do
        let(:value) { :a }
        it { is_expected.to eq(1) }
      end

      context 'given :unknown' do
        let(:value) { :unknown }
        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'given "unknown"' do
        let(:value) { 'unknown' }
        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end
  end
end
