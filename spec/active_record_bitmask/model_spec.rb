# frozen_string_literal: true

RSpec.describe ActiveRecordBitmask::Model do
  describe 'ClassMethods' do
    describe '.bitmask' do
      context 'without :as option' do
        subject { -> { with_bitmask(Variation, bitmask: []) {} } }
        it { is_expected.to raise_error(ArgumentError) }
      end

      context 'with :as option' do
        it 'builds mappings' do
          with_bitmask(Variation, bitmask: [:a]) do
            expect(Variation.bitmask_for(:bitmask)).to_not be_nil
          end
        end

        context 'sub class' do
          it 'inherits mappings' do
            with_bitmask(Variation, bitmask: [:a]) do
              expect(SubVariation.bitmask_for(:bitmask)).to be_present
            end
          end

          it 'does not overwrite bitmask' do
            with_bitmask(Variation, bitmask: [:a]) do
              expect { with_bitmask(SubVariation, bitmask: [:b]) {} }.to raise_error(ArgumentError)
              expect { with_bitmask(SubVariation, id: [:b]) {} }.to_not raise_error
            end
          end
        end
      end

      describe 'Accessors' do
        around do |example|
          with_bitmask(Post, bitmask: %i[a b c]) { example.run }
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
      end

      describe 'Scopes' do
        describe '.with_bitmask' do
          subject { Post.with_bitmask(*bitmask_or_attributes) }

          around do |example|
            with_bitmask(Post, bitmask: %i[a b c]) { example.run }
          end

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

        describe '.with_any_bitmask' do
          subject { Post.with_any_bitmask(*bitmask_or_attributes) }

          around do |example|
            with_bitmask(Post, bitmask: %i[a b c]) { example.run }
          end

          let!(:post_bitmask_1) { Post.create!(bitmask: [:a]) }
          let!(:post_bitmask_2) { Post.create!(bitmask: [:b]) }
          let!(:post_bitmask_3) { Post.create!(bitmask: %i[a b]) }

          context 'with :a' do
            let(:bitmask_or_attributes) { [:a] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_3) }
          end

          context 'with :b' do
            let(:bitmask_or_attributes) { [:a, :b] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_2, post_bitmask_3) }
          end

          context 'with 1' do
            let(:bitmask_or_attributes) { [1] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_3) }
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

    describe '.bitmask_for' do
      subject { Variation.bitmask_for(:bitmask) }

      around do |example|
        with_bitmask(Variation, bitmask: [:a]) { example.run }
      end

      it { is_expected.to be_a(ActiveRecordBitmask::Map) }
    end
  end
end
