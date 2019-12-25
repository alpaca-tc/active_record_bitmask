# frozen_string_literal: true

RSpec.describe ActiveRecordBitmask::BitmaskType do
  describe 'InstanceMethods' do
    describe '#type' do
      subject do
        instance.type
      end

      let(:instance) do
        described_class.new(name, map, sub_type)
      end

      let(:name) { :name }
      let(:map) { ActiveRecordBitmask::Map.new([]) }
      let(:sub_type) { ActiveModel::Type.lookup(:integer) }

      it 'delegates to sub_type' do
        is_expected.to eq(:integer)
      end
    end

    describe '#cast' do
      subject do
        instance.cast(value)
      end

      let(:instance) do
        described_class.new(name, map, sub_type)
      end

      let(:name) { :name }
      let(:map) { ActiveRecordBitmask::Map.new(%i[a b]) }
      let(:sub_type) { ActiveModel::Type.lookup(:integer) }

      context 'given nil' do
        let(:value) { nil }
        it { is_expected.to eq([]) }
      end

      context 'given []' do
        let(:value) { [] }
        it { is_expected.to eq([]) }
      end

      context 'given [:a]' do
        let(:value) { [:a] }
        it { is_expected.to eq([:a]) }
      end

      context 'given :a' do
        let(:value) { :a }
        it { is_expected.to eq([:a]) }
      end

      context 'given [:a, :b]' do
        let(:value) { %i[a b] }
        it { is_expected.to eq(%i[a b]) }
      end

      context 'given [:b, :a]' do
        let(:value) { %i[b a] }
        it { is_expected.to eq(%i[a b]) }
      end

      context 'given :invalid' do
        let(:value) { :invalid }
        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end

    describe '#serialize' do
      subject do
        instance.serialize(value)
      end

      let(:instance) do
        described_class.new(name, map, sub_type)
      end

      let(:name) { :name }
      let(:map) { ActiveRecordBitmask::Map.new(%i[a b]) }
      let(:sub_type) { ActiveModel::Type.lookup(:integer) }

      context 'given nil' do
        let(:value) { nil }
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

      context 'given [:b, :a]' do
        let(:value) { %i[b a] }
        it { is_expected.to eq(3) }
      end
    end

    describe '#deserialize' do
      subject do
        instance.deserialize(value)
      end

      let(:instance) do
        described_class.new(name, map, sub_type)
      end

      let(:name) { :name }
      let(:map) { ActiveRecordBitmask::Map.new(%i[a b]) }
      let(:sub_type) { ActiveModel::Type.lookup(:integer) }

      context 'given nil' do
        let(:value) { nil }
        it { is_expected.to eq([]) }
      end

      context 'given 0' do
        let(:value) { 0 }
        it { is_expected.to eq([]) }
      end

      context 'given 1' do
        let(:value) { 1 }
        it { is_expected.to eq([:a]) }
      end

      context 'given 2' do
        let(:value) { 2 }
        it { is_expected.to eq([:b]) }
      end

      context 'given 3' do
        let(:value) { 3 }
        it { is_expected.to eq(%i[a b]) }
      end

      context 'given 4' do
        let(:value) { 4 }
        it { is_expected.to eq([]) }
      end
    end

    describe '#changed_in_place?' do
      let(:instance) do
        described_class.new(name, map, sub_type)
      end

      let(:name) { :name }
      let(:map) { ActiveRecordBitmask::Map.new(%i[a b]) }
      let(:sub_type) { ActiveModel::Type.lookup(:integer) }

      subject do
        instance.changed_in_place?(a, b)
      end

      context 'given nil, nil' do
        let(:a) { nil }
        let(:b) { nil }

        it { is_expected.to be(false) }
      end

      context 'given nil, []' do
        let(:a) { nil }
        let(:b) { [] }

        it { is_expected.to be(true) }
      end

      context 'given 0, []' do
        let(:a) { 0 }
        let(:b) { [] }

        it { is_expected.to be(false) }
      end

      context 'given [], []' do
        let(:a) { [] }
        let(:b) { [] }

        it { is_expected.to be(false) }
      end

      context 'given [], 0' do
        let(:a) { [] }
        let(:b) { 0 }

        it { is_expected.to be(false) }
      end

      context 'given [], 1' do
        let(:a) { [] }
        let(:b) { 1 }

        it { is_expected.to be(true) }
      end
    end
  end
end
