RSpec.describe StringCheese::Engine do
  let(:engine) { described_class.new(vars, options) }
  let(:vars) {
    {
    var_1: 1,
    var_2: 2
    }
  }
  let(:options) { {} }

  describe 'data' do
    context 'when accesses incorrectly' do
      it 'is handled gracefully'
    end
  end

  describe '<var>=' do
    context 'when assigning to a value to a var' do
      let(:expected_results) { '1 and 2' }

      it 'returns the correct string' do
        expect(engine.var_1.and.var_2.to_s).to eq(expected_results)
        engine.var_1 = 3
        engine.var_2 = 4
        expect(engine.raw(', ').var_1.and.var_2.to_s(debug: true)).to eq('1 and 2, 3 and 4')
        engine.var_1 = 5
        engine.var_2 = 6
        expect(engine.raw(', ').var_1.and.var_2.to_s(debug: true)).to eq('1 and 2, 3 and 4, 5 and 6')
      end
    end

    context 'when assigning to a value to a label' do
      let(:expected_results) { 'New Var 1 Label and New Var 2 Label' }

      it 'returns the correct string' do
        expect(engine.var_1_label.var_1.and.var_2_label.var_2.to_s(debug: true)).to eq('var_1 1 and var_2 2')
        engine.var_1_label = 'New Var 1 Label'
        engine.var_2_label = 'New Var 2 Label'
        expect(engine.var_1_label.and.var_2_label.to_s(debug: true)).to eq('var_1 1 and var_2 2 New Var 1 Label and New Var 2 Label')
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
