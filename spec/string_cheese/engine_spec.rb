RSpec.describe StringCheese::Engine do
  let(:engine) { described_class.new(vars, options) }
  let(:vars) {
    {
    var_1: 1,
    var_2: 2
    }
  }
  let(:options) { {} }

  describe '<var>=' do
    context 'when assigning to a value to a var' do
      let(:expected_results) { '[1] and [2]' }

      it 'returns the correct string' do
        expect(engine.var_1.and.var_2.to_s).to eq(expected_results)
        engine.var_1 = 3
        engine.var_2 = 4
        expect(engine.raw(', ').var_1.and.var_2.to_s(debug: true)).to eq('[1] and [2], [3] and [4]')
        engine.var_1 = 5
        engine.var_2 = 6
        expect(engine.raw(', ').var_1.and.var_2.to_s(debug: true)).to eq('[1] and [2], [3] and [4], [5] and [6]')
      end
    end

    context 'when assigning to a value to a label' do
      let(:expected_results) { 'New Var 1 Label and New Var 2 Label' }

      it 'returns the correct string' do
        expect(engine.var_1_label.var_1.and.var_2_label.var_2.to_s(debug: true)).to eq('var_1 [1] and var_2 [2]')
        engine.var_1_label = 'New Var 1 Label'
        engine.var_2_label = 'New Var 2 Label'
        expect(engine.var_1_label.and.var_2_label.to_s(debug: true)).to eq('var_1 [1] and var_2 [2] New Var 1 Label and New Var 2 Label')
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
      let(:expected_results) { '[1] and [2]' }

      it 'returns the correct string' do
        expect(engine.var_1.and.var_2.to_s).to eq(expected_results)
      end
    end

    context 'with labels' do
      let(:expected_results) { 'var_1: [1] and var_2: [2]' }

      it 'returns the correct string' do
        expect(engine.var_1_label.raw(': ').var_1.and.var_2_label.raw(': ').var_2.to_s).to eq(expected_results)
      end
    end
  end
end
