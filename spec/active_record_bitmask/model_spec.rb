# frozen_string_literal: true

RSpec.describe ActiveRecordBitmask::Model do
  describe 'ClassMethods' do
    describe '.bitmask' do
      context 'without attributes' do
        it { expect { with_bitmask(Variation, bitmask: []) {} }.to raise_error(ArgumentError) }
      end

      context 'with attributes' do
        it 'builds mappings' do
          with_bitmask(Variation, bitmask: [:a]) do
            expect(Variation.bitmask_for(:bitmask)).to be_a(ActiveRecordBitmask::Map)
          end
        end

        context 'sub class' do
          it 'inherits mappings' do
            with_bitmask(Variation, bitmask: [:a]) do
              inherited = Class.new(Variation)
              expect(inherited.bitmask_for(:bitmask).keys).to eq([:a])
            end
          end

          it 'can overwrite bitmask' do
            with_bitmask(Variation, bitmask: [:a]) do
              inherited = Class.new(Variation)
              inherited.bitmask(bitmask: [:b])

              expect(Variation.bitmask_for(:bitmask).keys).to eq([:a])
              expect(inherited.bitmask_for(:bitmask).keys).to eq([:b])
            end
          end
        end
      end

      describe 'Accessors' do
        around do |example|
          with_bitmask(klass, bitmask: %i[a b c]) { example.run }
        end

        let(:klass) do
          Class.new(Post)
        end

        describe 'defined composed object' do
          describe '#bitmask' do
            subject { instance.bitmask }

            context 'initial' do
              let(:instance) { klass.create! }

              it 'saves as 0' do
                result = klass.connection.exec_query("SELECT bitmask, bitmask_zero FROM #{klass.table_name} WHERE id = #{instance.id}")
                row = result[0]

                database_value = row['bitmask']
                expect(database_value).to be_nil

                database_value = row['bitmask_zero']
                expect(database_value).to eq(0)
              end
            end

            context 'bitmask is [:a]' do
              let(:instance) { klass.create!(bitmask: [:a]) }
              it { is_expected.to eq([:a]) }
            end

            context 'bitmask is 1' do
              let(:instance) { klass.create!(bitmask: 1) }
              it { is_expected.to eq([:a]) }
            end
          end

          describe '#bitmask@<<' do
            subject { instance.bitmask }
            let(:instance) { klass.new }

            before do
              instance.bitmask << :a
            end

            it { is_expected.to eq([:a]) }
          end

          describe '#bitmask.clear' do
            subject { instance.bitmask }
            let(:instance) { klass.new(bitmask: [:a]) }

            before do
              instance.bitmask.clear
            end

            it { is_expected.to eq([]) }
          end

          describe '#bitmask.push' do
            subject { instance.bitmask }
            let(:instance) { klass.new }

            before do
              instance.bitmask.push(:a)
            end

            it { is_expected.to eq([:a]) }
          end

          describe '#bitmask@+=' do
            subject { instance.bitmask }
            let(:instance) { klass.new }

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
            let(:instance) { klass.new }

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
          subject { klass.with_bitmask(*bitmask_or_attributes) }

          around do |example|
            with_bitmask(klass, bitmask: %i[a b c]) { example.run }
          end

          let(:klass) do
            Class.new(Post)
          end

          let!(:post_bitmask_nil) { klass.create!(bitmask: nil) }
          let!(:post_bitmask_blank) { klass.create!(bitmask: []) }
          let!(:post_bitmask_1) { klass.create!(bitmask: [:a]) }
          let!(:post_bitmask_2) { klass.create!(bitmask: [:b]) }
          let!(:post_bitmask_3) { klass.create!(bitmask: %i[a b]) }

          context 'with no argument' do
            let(:bitmask_or_attributes) { [] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_2, post_bitmask_3) }
          end

          context 'with :a' do
            let(:bitmask_or_attributes) { [:a] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_3) }
          end

          context 'with 1' do
            let(:bitmask_or_attributes) { [1] }
            it { expect { subject }.to raise_error(ArgumentError) }
          end

          context 'with :unknown' do
            let(:bitmask_or_attributes) { [:unknown] }
            it { expect { subject }.to raise_error(ArgumentError) }
          end
        end

        describe '.with_any_bitmask' do
          subject { klass.with_any_bitmask(*bitmask_or_attributes) }

          around do |example|
            with_bitmask(klass, bitmask: %i[a b c]) { example.run }
          end

          let(:klass) do
            Class.new(Post)
          end

          let!(:post_bitmask_nil) { klass.create!(bitmask: nil) }
          let!(:post_bitmask_blank) { klass.create!(bitmask: []) }
          let!(:post_bitmask_1) { klass.create!(bitmask: [:a]) }
          let!(:post_bitmask_2) { klass.create!(bitmask: [:b]) }
          let!(:post_bitmask_3) { klass.create!(bitmask: %i[a b]) }

          context 'with no argument' do
            let(:bitmask_or_attributes) { [] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_2, post_bitmask_3) }
          end

          context 'with :a' do
            let(:bitmask_or_attributes) { [:a] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_3) }
          end

          context 'with :b' do
            let(:bitmask_or_attributes) { %i[a b] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_2, post_bitmask_3) }
          end

          context 'with 1' do
            let(:bitmask_or_attributes) { [1] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_3) }
          end

          context 'with :unknown' do
            let(:bitmask_or_attributes) { [:unknown] }
            it { expect { subject }.to raise_error(ArgumentError) }
          end
        end

        describe '.with_exact_bitmask' do
          subject { klass.with_exact_bitmask(*bitmask_or_attributes) }

          around do |example|
            with_bitmask(klass, bitmask: %i[a b c]) { example.run }
          end

          let(:klass) do
            Class.new(Post)
          end

          let!(:post_bitmask_blank) { klass.create!(bitmask: []) }
          let!(:post_bitmask_1) { klass.create!(bitmask: [:a]) }
          let!(:post_bitmask_2) { klass.create!(bitmask: [:b]) }
          let!(:post_bitmask_3) { klass.create!(bitmask: %i[a b]) }

          context 'with :a' do
            let(:bitmask_or_attributes) { [:a] }
            it { is_expected.to contain_exactly(post_bitmask_1) }
          end

          context 'with [:a, :b]' do
            let(:bitmask_or_attributes) { %i[a b] }
            it { is_expected.to contain_exactly(post_bitmask_3) }
          end

          context 'with 1' do
            let(:bitmask_or_attributes) { [1] }
            it { is_expected.to contain_exactly(post_bitmask_1) }
          end

          context 'with []' do
            let(:bitmask_or_attributes) { [] }
            it { is_expected.to contain_exactly(post_bitmask_blank) }
          end

          context 'with :unknown' do
            let(:bitmask_or_attributes) { [:unknown] }
            it { expect { subject }.to raise_error(ArgumentError) }
          end
        end

        describe '.without_bitmask' do
          subject { klass.without_bitmask(*bitmask_or_attributes) }

          around do |example|
            with_bitmask(klass, bitmask: %i[a b c]) { example.run }
          end

          let(:klass) do
            Class.new(Post)
          end

          let!(:post_bitmask_blank) { klass.create!(bitmask: []) }
          let!(:post_bitmask_1) { klass.create!(bitmask: [:a]) }
          let!(:post_bitmask_2) { klass.create!(bitmask: [:b]) }
          let!(:post_bitmask_3) { klass.create!(bitmask: %i[a b]) }

          context 'with :a' do
            let(:bitmask_or_attributes) { [:a] }
            it { is_expected.to contain_exactly(post_bitmask_blank, post_bitmask_2) }
          end

          context 'with :b' do
            let(:bitmask_or_attributes) { [:b] }
            it { is_expected.to contain_exactly(post_bitmask_blank, post_bitmask_1) }
          end

          context 'with [:a, :b]' do
            let(:bitmask_or_attributes) { %i[a b] }
            it { is_expected.to contain_exactly(post_bitmask_blank) }
          end

          context 'with 1' do
            let(:bitmask_or_attributes) { [1] }
            it { is_expected.to contain_exactly(post_bitmask_blank, post_bitmask_2) }
          end

          context 'with []' do
            let(:bitmask_or_attributes) { [] }
            it { is_expected.to contain_exactly(post_bitmask_blank) }
          end

          context 'with 0' do
            let(:bitmask_or_attributes) { [0] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_2, post_bitmask_3) }
          end

          context 'with nil' do
            let(:bitmask_or_attributes) { [nil] }
            it { is_expected.to contain_exactly(post_bitmask_1, post_bitmask_2, post_bitmask_3) }
          end

          context 'without argument' do
            let(:bitmask_or_attributes) { [] }
            it { is_expected.to contain_exactly(post_bitmask_blank) }
          end

          context 'with :unknown' do
            let(:bitmask_or_attributes) { [:unknown] }
            it { expect { subject }.to raise_error(ArgumentError) }
          end
        end

        describe '.no_bitmask' do
          subject { klass.no_bitmask }

          around do |example|
            with_bitmask(klass, bitmask: %i[a b c]) { example.run }
          end

          let(:klass) do
            Class.new(Post)
          end

          let!(:post_bitmask_0) { klass.create!(bitmask: []) }
          let!(:post_bitmask_null) { klass.create!(bitmask: nil) }
          let!(:post_bitmask_1) { klass.create!(bitmask: [:a]) }

          it { is_expected.to contain_exactly(post_bitmask_0, post_bitmask_null) }
        end
      end
    end

    describe '.bitmask_for' do
      subject { klass.bitmask_for(:bitmask) }

      around do |example|
        with_bitmask(klass, bitmask: [:a]) { example.run }
      end

      let(:klass) do
        Class.new(Variation)
      end

      it { is_expected.to be_a(ActiveRecordBitmask::Map) }
    end
  end
end
