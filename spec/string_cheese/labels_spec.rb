RSpec.describe StringCheese::Labels do
  describe '.var_label?' do
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

  describe '.var_label_exists?' do
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

  describe '.var_label_for' do
    context 'when var is not a label' do
      it 'returns the label' do
        expect(described_class.send(:label_for, :var)).to eq(:var_label)
      end
    end

    context 'when var is already a label' do
      it 'returns nil' do
        expect(described_class.send(:label_for, :var_label)).to be_nil
      end
    end
  end

  describe '.var_labels' do
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

    context 'when passed vars with labels' do
      let(:vars) { var_vars.merge(var_labels) }

      it 'returns the labels' do
        expect(described_class.send(:labels, vars)).to eq(var_labels)
      end
    end

    context 'when passed vars with no labels' do
      let(:vars) { var_vars }

      it 'returns the labels' do
        expect(described_class.send(:labels, vars)).to eq({})
      end
    end
  end

  describe '.var_labels_create' do
    let(:vars) {
      {
      var_1: 1,
      var_2: 2
      }
    }
    let(:expected_vars) {
      {
      var_1_label: :var_1,
      var_2_label: :var_2
      }
    }

    it 'returns the labels' do
      expect(described_class.send(:labels_create, vars)).to eq(expected_vars)
    end
  end

  describe '.var_labels_merge' do
    let(:vars) {
      {
      var_1: 1,
      var_1_label: 'my var_1 label',
      var_2: 2
      }
    }
    let(:var_labels) { StringCheese.send(:labels_create, vars) }
    let(:expected_vars) {
      {
      var_1: 1,
      var_1_label: 'my var_1 label',
      var_2: 2,
      var_2_label: :var_2
      }
    }

    it 'returns the labels' do
      expect(StringCheese.send(:labels_merge, vars, var_labels)).to eq(expected_vars)
    end
  end
end
