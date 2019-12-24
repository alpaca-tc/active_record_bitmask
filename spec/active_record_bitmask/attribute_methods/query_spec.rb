# frozen_string_literal: true

RSpec.describe ActiveRecordBitmask::AttributeMethods::Query do
  around do |example|
    with_bitmask(Post, :bitmask, as: [:a]) do
      example.run
    end
  end

  context '#attribute?' do
    subject { instance.public_send(:"#{attribute}?") }
    let(:instance) { Post.new }

    context 'with attribute' do
      let(:attribute) { 'id' }

      context 'if value is not present' do
        it { is_expected.to be false }
      end

      context 'if value is present' do
        before do
          instance.id = 1
        end

        it { is_expected.to be true }
      end
    end

    context 'with bitmask attribute' do
      let(:attribute) { 'bitmask' }

      context 'if value is not present' do
        it { is_expected.to be false }
      end

      context 'if value is present' do
        before do
          instance.bitmask = 1
        end

        it { is_expected.to be true }

        context 'with :a' do
          subject { instance.bitmask?(:a) }
          it { is_expected.to be true }
        end

        context 'with :unknown' do
          subject { instance.bitmask?(:unknown) }
          it { expect { subject }.to raise_error(ArgumentError) }
        end
      end
    end
  end
end
