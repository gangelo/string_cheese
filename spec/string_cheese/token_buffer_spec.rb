# frozen_string_literal: true

RSpec.describe StringCheese::TokenBuffer do
  TextToken = StringCheese::TextToken

  let(:buffer) { described_class.new }
  let(:token) { TextToken.new('token') }

  describe '<<' do
    context 'when a non-token object is pushed' do
      let(:token) { :not_a_token }

      it 'raises an error' do
        expect { buffer << token }.to raise_error(ArgumentError, /Param \[token\] is not a Token/)
      end
    end

    context 'when a token is pushed' do
      it 'token is added to the buffer' do
        expect(buffer << token).to eq([token])
      end
    end

    describe 'any?' do
      it 'returns false if buffer is empty' do
        expect(buffer.any?).to eq(false)
      end

      it 'returns true if buffer is not empty' do
        buffer << token
        expect(buffer.any?).to eq(true)
      end
    end

    describe 'clear_buffer' do
      it 'clears the buffer' do
        buffer << token
        expect(buffer.any?).to eq(true)
        buffer.clear_buffer
        expect(buffer.any?).to eq(false)
      end
    end

    describe 'update!' do
      context 'when updating the current buffer' do
        let(:var_1) { StringCheese::VarToken.new(:var_1, 1) }
        let(:var_2) { StringCheese::VarToken.new(:var_2, 2) }
        let(:var_1_label) { StringCheese::LabelToken.new(:var_1_label, :var_1) }
        let(:var_2_label) { StringCheese::LabelToken.new(:var_2_label, :var_2) }

        let(:vars_and_labels) {
          [var_1, var_2, var_1_label, var_2_label]
        }

        let(:update_vars) { var_1.to_h.merge(var_2.to_h) }
        let(:update_labels) { var_1_label.to_h.merge(var_2_label.to_h) }

        it 'updates the buffer' do
          buffer << var_1
          buffer << var_2
          buffer << var_1_label
          buffer << var_2_label
          expect(buffer.send(:buffer)).to include(var_1, var_2, var_1_label, var_2_label)
          expect(buffer.send(:buffer).map { |t| "#{t.key}#{t.value}"} ==
                 vars_and_labels.map { |t| "#{t.key}#{t.value}"}).to eq(true)
          var_1.value = 11
          var_2.value = 22
          var_1_label.value = 'New Var 1 Label'
          var_2_label.value = 'New Var 2 Label'
          buffer.update!(update_vars, update_labels)
          expect(buffer.send(:buffer).map { |t| "#{t.key}#{t.value}"} ==
                 vars_and_labels.map { |t| "#{t.key}#{t.value}"}).to eq(true)
        end
      end
    end
  end
end
