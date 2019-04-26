RSpec.describe StringCheese::Labels do
  describe '.create_labels' do
    let(:vars) {
      { var_1: 1,
        var_2: 2 }
    }
    let(:expected_vars) {
      { var_1_label: :var_1,
        var_2_label: :var_2 }
    }

    it 'returns the labels' do
      expect(described_class.send(:create_labels, vars)).to eq(expected_vars)
    end
  end

  describe '.label_exists?' do
    let(:vars) {
      { var_1: 1,
        var_2: 2 }
    }

    context 'when the label does not exist' do
      it 'returns false' do
        expect(described_class.send(:label_exists?, :bad_label, vars)).to eq(false)
      end
    end

    context 'when the label exists' do
      it 'returns true' do
        expect(described_class.send(:label_exists?, :var_1, vars)).to eq(true)
      end
    end
  end

  describe '.label?' do
    context 'when a label' do
      it 'returns true' do
        expect(StringCheese.send(:label?, :good_label)).to be(true)
      end
    end

    context 'when not a label' do
      it 'returns false' do
        expect(StringCheese.send(:label?, :not_a_label_x)).to be(false)
      end
    end
  end

  describe '.merge_labels' do
    let(:vars) {
      { var_1: 1,
        var_1_label: 'my var_1 label',
        var_2: 2 }
    }
    let(:var_labels) { StringCheese.send(:create_labels, vars) }
    let(:expected_vars) {
      { var_1: 1,
        var_1_label: 'my var_1 label',
        var_2: 2,
        var_2_label: :var_2 }
    }

    it 'returns the labels' do
      expect(StringCheese.send(:merge_labels, vars, var_labels)).to eq(expected_vars)
    end
  end
end
