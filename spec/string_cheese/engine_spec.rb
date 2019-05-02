# frozen_string_literal: true

RSpec.describe StringCheese::Engine do
  let(:engine) { described_class.new(vars, options) }
  let(:vars) do
    {
      var_1: 1,
      var_2: 2
    }
  end
  let(:options) { {} }

  describe 'data_repository.attr_data' do
    context 'when accesses incorrectly' do
      it 'is handled gracefully'
    end
  end

  describe '' do
    context '' do
    end
  end

  describe '<label>=' do
    context 'when assigning a value to an existing label' do
      let(:expected_results) { 'New Var 1 Label and New Var 2 Label' }

      it 'assigns the value' do
        engine.var_1_label = 'New Label Value 1'
        engine.var_2_label = 'New Label Value 2'
        expect(engine.data_repository.attr_data.var_1_label).to eq('New Label Value 1')
        expect(engine.data_repository.attr_data.var_2_label).to eq('New Label Value 2')
      end
    end

    context 'when assigning a value to a label that does not exist' do
      it 'creates a new label and assigns the value' do
        engine.new_1_label = 'New Label 1'
        engine.new_2_label = 'New Label 2'
        expect(engine.data_repository.attr_data.new_1_label).to eq('New Label 1')
        expect(engine.data_repository.attr_data.new_2_label).to eq('New Label 2')
      end
    end
  end

  describe '<var>=' do
    context 'when assigning to a value to an existing var' do
      let(:expected_results) { '1 and 2' }

      it 'assigns the value' do
        engine.var_1 = 11
        engine.var_2 = 22
        expect(engine.data_repository.attr_data.var_1).to eq(11)
        expect(engine.data_repository.attr_data.var_2).to eq(22)
      end
    end

    context 'when assigning a value to a var that does not exist' do
      it 'creates a new label and assigns the value' do
        engine.new_var_1 = :new_var_1
        engine.new_var_2 = :new_var_2
        expect(engine.data_repository.attr_data.new_var_1).to eq(:new_var_1)
        expect(engine.data_repository.attr_data.new_var_2).to eq(:new_var_2)
      end
    end
  end

  describe 'to_s' do
    context 'with no vars and no labels' do
      let(:expected_results) { '' }

      it 'returns an empty string' do
        expect(engine.to_s).to eq(expected_results)
      end
    end

    context 'with vars' do
      let(:expected_results) { '1 and 2' }

      it 'returns the correct string' do
        expect(engine.var_1.and.var_2.to_s).to eq(expected_results)
      end
    end

    context 'with labels' do
      let(:expected_results) { 'var_1 var_2' }

      it 'returns the correct string' do
        expect(engine.var_1_label.var_2_label.to_s).to eq(expected_results)
      end
    end

    context 'with vars and labels' do
      let(:expected_results) { 'var_1: 1 and var_2: 2' }

      it 'returns the correct string' do
        expect(engine.var_1_label.raw(': ').var_1.and.var_2_label.raw(': ').var_2.to_s).to eq(expected_results)
      end
    end

    context 'with raw tokens' do
      context 'when a raw token is the very first token' do
        it 'preserves escape sequences if entered by the user' do
          expect(engine.raw(" \bIt \bworks!\b ").and.that.raw(' :) ').end.to_s).to eq(" \bIt \bworks!\b and that :) end")
        end
      end

      context 'when raw tokens are consecutive' do
        let(:expected_results) { 'This, and that works!' }

        it 'returns the correct string' do
          expect(engine.raw('This').raw(', ').raw('and').raw(' that ').raw('works!').to_s).to eq(expected_results)
        end
      end

      context 'when raw token contains invalid UTF-8 characters' do
        it 'the token properly is flagged' do
          expect(engine.Bad.raw(' raw data').raw(": \xFF!").to_s).to eq('Bad raw data: <invalid utf-8 sequence>!')
        end
      end
    end
  end
end
