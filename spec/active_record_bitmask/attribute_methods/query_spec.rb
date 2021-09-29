# frozen_string_literal: true

RSpec.describe ActiveRecordBitmask::AttributeMethods::Query do
  around do |example|
    with_bitmask(Post, bitmask: [:a]) do
      example.run
    end
  end

  context '#attribute?' do
    subject do
      instance.public_send(:"#{attribute}?", *args)
    end

    let(:instance) { Post.new }
    let(:args) { [] }

    context 'with attribute' do
      let(:attribute) { 'column' }

      context 'if value is not present' do
        it { is_expected.to be false }
      end

      context 'if value is present' do
        before do
          instance.column = 1
        end

        it { is_expected.to be true }
      end
    end

    if ActiveRecord.gem_version < Gem::Version.create('7.0.0.alpha1')
      shared_examples_for 'deprecation warning' do
        it 'renders deprecation warning' do
          allow(ActiveSupport::Deprecation).to receive(:warn)

          subject

          expect(ActiveSupport::Deprecation).to have_received(:warn)
            .with("`#{attribute}?(*args)` is deprecated and will be removed in next major version. Call `#{attribute}_bitmask?(*args)` instead.")
        end
      end

      context 'with bitmask attribute' do
        let(:attribute) { 'bitmask' }

        context 'if value is not present' do
          before do
            instance.bitmask = value
          end

          context '0' do
            let(:value) do
              0
            end

            it { is_expected.to be false }
          end

          context '[]' do
            let(:value) do
              []
            end

            it { is_expected.to be false }
          end

          context 'nil' do
            let(:value) do
              nil
            end

            it { is_expected.to be false }
          end
        end

        context 'if value is present' do
          before do
            instance.bitmask = 1
          end

          it { is_expected.to be true }

          context 'without argument' do
            let(:args) do
              []
            end

            it { is_expected.to be true }
          end

          context 'with :a' do
            let(:args) do
              [:a]
            end

            it { is_expected.to be true }
            it_should_behave_like 'deprecation warning'
          end

          context 'with "a"' do
            let(:args) do
              ['a']
            end

            it { is_expected.to be true }
            it_should_behave_like 'deprecation warning'
          end

          context 'with :unknown' do
            let(:args) do
              [:unknown]
            end

            it { expect { subject }.to raise_error(ArgumentError) }
          end
        end
      end
    end
  end

  context '#attribute_bitmask?' do
    subject do
      instance.public_send(:"#{attribute}_bitmask?", *args)
    end

    let(:instance) { Post.new }
    let(:args) { [] }

    context 'with attribute' do
      let(:attribute) { 'column' }

      context 'if value is not present' do
        it { is_expected.to be false }
      end

      context 'if value is present' do
        before do
          instance.column = 1
        end

        it { is_expected.to be true }
      end
    end

    context 'with bitmask attribute' do
      let(:attribute) { 'bitmask' }

      context 'if value is not present' do
        before do
          instance.bitmask = value
        end

        context '0' do
          let(:value) do
            0
          end

          it { is_expected.to be false }
        end

        context '[]' do
          let(:value) do
            []
          end

          it { is_expected.to be false }
        end

        context 'nil' do
          let(:value) do
            nil
          end

          it { is_expected.to be false }
        end
      end

      context 'if value is present' do
        before do
          instance.bitmask = 1
        end

        it { is_expected.to be true }

        context 'without argument' do
          let(:args) do
            []
          end

          it { is_expected.to be true }
        end

        context 'with :a' do
          let(:args) do
            [:a]
          end

          it { is_expected.to be true }
        end

        context 'with "a"' do
          let(:args) do
            ['a']
          end

          it { is_expected.to be true }
        end

        context 'with :unknown' do
          let(:args) do
            [:unknown]
          end

          it { expect { subject }.to raise_error(ArgumentError) }
        end
      end
    end
  end
end
