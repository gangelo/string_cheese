RSpec.describe StringCheese do
  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  let(:vars) {
    {
    var_1: 1,
    var_2: 2
    }
  }
  let(:options) { {} }
  let(:engine) { described_class.create(vars, options) }

  describe '.create' do
    it 'returns the engine' do
      expect(engine).to be_kind_of(StringCheese::Engine)
    end

    it 'returns the engine with the right vars' do
      expect(engine).to respond_to(:var_1)
      expect(engine).to respond_to(:var_2)
      expect(engine).to respond_to(:var_1_label)
      expect(engine).to respond_to(:var_2_label)
    end
  end

  describe '.create_engine' do
    let(:create_engine) { described_class.send(:create_engine, vars, options) }

    it 'creates the engine' do
      expect(create_engine).to be_kind_of(StringCheese::Engine)
    end

    it 'creates the engine with the right vars' do
      expect(create_engine).to respond_to(:var_1)
      expect(create_engine).to respond_to(:var_2)
      expect(create_engine).to_not respond_to(:var_1_label)
      expect(create_engine).to_not respond_to(:var_2_label)
    end
  end
end
