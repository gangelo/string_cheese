RSpec.describe StringCheese::Engine do
  let(:engine) { described_class.new(vars, options) }
  let(:vars) { OpenStruct.new(vars_hash) }
  let(:options) {}

  describe 'to_s' do
    context 'with vars' do
      let(:vars_hash) { { var_1: 1, var_2: 2 } }
      let(:expected_results) { '[1] and [2]' }

      it 'returns the correct string' do
        expect(engine.var_1.and.var_2.to_s).to eq(expected_results)
      end
    end

    context 'with labels' do
      let(:vars_hash) { { var_1: 1, var_2: 2 } }
      let(:expected_results) { 'var_1_label: [1] and var_2_label: [2]' }

      it 'returns the correct string' do
        expect(engine.var_1_label.raw(':').var_1.and.var_2_label.raw(':').var_2.to_s).to eq(expected_results)
      end
    end
  end
end
