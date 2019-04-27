RSpec.describe StringCheese::Vars do
  describe '.extract_labels' do
    context 'when vars and lables are passed' do
      let(:var_vars) {
        {
        var_1: 1,
        var_2: 2
        }
      }
      let(:var_labels) {
        {
        var_1_label: :var_1,
        var_2_label: :var_2
        }
      }
      let(:vars) { var_vars.merge(var_labels) }

      it 'returns the correct vars and labels' do
        expect(described_class.send(:extract_labels, vars)).to eq([var_vars, var_labels])
      end
    end
  end

  describe '.vars' do
    let(:var_vars) {
      {
      var_1: 1,
      var_2: 2
      }
    }
    let(:var_labels) {
      {
      var_1_label: :var_1,
      var_2_label: :var_2
      }
    }

    # context 'when passed vars with vars' do
    #   let(:vars) { var_vars.merge(var_labels) }

    #   it 'returns the labels' do
    #     expect(described_class.send(:vars, vars)).to eq(var_vars)
    #   end
    # end

    # context 'when passed vars with no vars' do
    #   let(:vars) { var_labels }

    #   it 'returns the labels' do
    #     expect(described_class.send(:vars, vars)).to eq({})
    #   end
    # end
  end
end
