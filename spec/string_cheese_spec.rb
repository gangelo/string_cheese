# frozen_string_literal: true

RSpec.describe StringCheese do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  let(:vars) do
    {
      var_1: 1,
      var_2: 2
    }
  end
  let(:options) { { labels: true } }
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

  describe '.create_with_debug' do
    let(:engine) { described_class.send(:create_with_debug, vars, options) }

    it 'creates an engine with debug enabled' do
      expect(engine.data.options.debug?).to eq(true)
    end
  end

  describe '.create_with_linter' do
    let(:engine) { described_class.send(:create_with_linter, vars, options) }

    it 'creates an engine with linter enabled' do
      expect(engine.data.options.linter?).to eq(true)
    end
  end

  describe '.create_with_linter' do
    let(:engine) { described_class.send(:create_with_linter, vars, options) }

    context 'when calling a method that is missing' do
      it 'raises the super NoMethodError' do
        expect { engine.bad_call }.to raise_error(NoMethodError, /undefined method `bad_call'/)
      end

      skip 'does not raise the string_cheese NoMethodError' do
        expect { engine.bad_call }.to raise_error(NoMethodError)
        RSpec::Expectations.configuration.on_potential_false_positives = :nothing
        expect { engine.bad_call }.to_not raise_error(NoMethodError, /from string_cheese'/)
      end
    end
  end
end
