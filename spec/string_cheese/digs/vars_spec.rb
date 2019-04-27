RSpec.describe StringCheese::Digs::Vars do
  let(:vars) { var_vars.merge(var_labels).extend(described_class) }
  let(:var_labels) { {} }

  context 'extract_labels!' do
    context 'when passed only vars' do
      context 'with the default label option' do
        let(:var_vars) { { var_1: 1, var_2: 2, var_3: 3 } }
        let(:expected_labels) { { var_1_label: :var_1, var_2_label: :var_2, var_3_label: :var_3 } }

        it 'returns the vars and auto-generated labels' do
          expect(vars.extract_labels!).to eq([var_vars, expected_labels])
        end
      end

      context 'with the labels: true option' do
        let(:var_vars) { { var_1: 1, var_2: 2, var_3: 3 } }
        let(:var_labels) { { var_1_label: :var_1, var_2_label: :var_2, var_3_label: :var_3 } }

        it 'returns the vars and auto-created labels' do
          expect(vars.extract_labels!(labels: true)).to eq([var_vars, var_labels])
        end
      end
    end

    context 'when passed vars and labels' do
      let(:var_vars) { { var_1: 1, var_2: 2, var_3: 3 } }

      context 'with labels: true option' do
        let(:var_labels) { { var_1_label: :var_1, var_2_label: :var_2, var_3_label: :var_3 } }

        it 'returns the correct vars and labels' do
          expect(vars.extract_labels!).to eq([var_vars, var_labels])
        end
      end

      context 'with labels: false option' do
        let(:var_labels) { { var_2_label: :var_2 } }

        it 'returns the correct vars and labels' do
          expect(vars.extract_labels!(labels: false)).to eq([var_vars, var_labels])
        end
      end
    end

    context 'when passed vars and custom labels' do
      let(:var_vars) { { var_1: 1, var_2: 2, var_3: 3 } }

      context 'with labels: true option' do
        let(:var_labels) { { var_2_label: 'Var 2 Label' } }
        let(:expected_labels) { { var_1_label: :var_1, var_2_label: 'Var 2 Label', var_3_label: :var_3 } }

        it 'returns the vars and preserves the custom labels' do
          expect(vars.extract_labels!(labels: true)).to eq([var_vars, expected_labels])
        end
      end

      context 'with labels: false option' do
        let(:var_labels) { { var_2_label: 'Var 2 Label' } }

        it 'returns the vars and preserves the custom labels' do
          expect(vars.extract_labels!(labels: false)).to eq([var_vars, var_labels])
        end
      end
    end
  end
end
