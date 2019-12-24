# frozen_string_literal: true

RSpec.describe ActiveRecordBitmaskAttributes::Definition do
  describe '.define_methods' do
    around do |example|
      with_bitmask(Post, :bitmask, as: %i[a b c]) { example.run }
    end

    describe 'defined composed object' do
      describe '#bitmask' do
        subject { instance.bitmask }

        context 'bitmask is [:a]' do
          let(:instance) { Post.create!(bitmask: [:a]) }
          it { is_expected.to eq([:a]) }
        end

        context 'bitmask is 1' do
          let(:instance) { Post.create!(bitmask: 1) }
          it { is_expected.to eq([:a]) }
        end
      end

      describe '#bitmask@<<' do
        subject { instance.bitmask }
        let(:instance) { Post.new }

        before do
          instance.bitmask << :a
        end

        it { is_expected.to eq([:a]) }
      end

      describe '#bitmask.clear' do
        subject { instance.bitmask }
        let(:instance) { Post.new(bitmask: [:a]) }

        before do
          instance.bitmask.clear
        end

        it { is_expected.to eq([]) }
      end

      describe '#bitmask.push' do
        subject { instance.bitmask }
        let(:instance) { Post.new }

        before do
          instance.bitmask.push(:a)
        end

        it { is_expected.to eq([:a]) }
      end

      describe '#bitmask@+=' do
        subject { instance.bitmask }
        let(:instance) { Post.new }

        before do
          instance.bitmask += [bitmask]
        end

        context 'bitmask is :a' do
          let(:bitmask) { :a }

          it 'adds bitmask value' do
            is_expected.to eq([:a])
          end
        end
      end

      describe '#bitmask=' do
        subject { instance.bitmask }
        let(:instance) { Post.new }

        before do
          instance.bitmask = bitmask
        end

        context 'bitmask is nil' do
          let(:bitmask) { nil }
          it { is_expected.to eq([]) }
        end

        context 'bitmask is 1' do
          let(:bitmask) { 1 }
          it { is_expected.to eq([:a]) }
        end

        context 'bitmask is :a' do
          let(:bitmask) { :a }
          it { is_expected.to eq([:a]) }
        end

        context 'bitmask is [:c]' do
          let(:bitmask) { [:c] }
          it { is_expected.to eq([:c]) }
        end

        context 'bitmask is []' do
          let(:bitmask) { [] }
          it { is_expected.to eq([]) }
        end
      end
    end

    describe 'defined scopes' do
      describe '.with_bitmask' do
        subject { Post.with_bitmask(*bitmask_or_attributes) }

        let!(:post_bitmask_1) { Post.create!(bitmask: [:a]) }
        let!(:post_bitmask_2) { Post.create!(bitmask: [:b]) }
        let!(:post_bitmask_3) { Post.create!(bitmask: %i[a b]) }

        context 'with :a' do
          let(:bitmask_or_attributes) { [:a] }
          it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_3) }
        end

        context 'with 1' do
          let(:bitmask_or_attributes) { [1] }
          it { expect { subject }.to raise_error(ArgumentError) }
        end

        context 'with nil' do
          let(:bitmask_or_attributes) { [] }
          it { is_expected.to be_empty }
        end

        context 'with :unknown' do
          let(:bitmask_or_attributes) { [:unknown] }
          it { expect { subject }.to raise_error(ArgumentError) }
        end
      end
    end
  end
end
