# frozen_string_literal: true

RSpec.describe StringCheese::Vars do
  describe '.extract_labels' do
    context 'when vars and lables are passed' do
      let(:var_vars) do
        {
          var_1: 1,
          var_2: 2
        }
      end
      let(:var_labels) do
        {
          var_1_label: :var_1,
          var_2_label: :var_2
        }
      end
      let(:vars) { var_vars.merge(var_labels) }

      it 'returns the correct vars and labels' do
        expect(described_class.send(:extract_labels, vars)).to eq([var_vars, var_labels])
      end
    end
  end

  describe '.vars' do
    let(:var_vars) do
      {
        var_1: 1,
        var_2: 2
      }
    end
    let(:var_labels) do
      {
        var_1_label: :var_1,
        var_2_label: :var_2
      }
    end
  end
end
