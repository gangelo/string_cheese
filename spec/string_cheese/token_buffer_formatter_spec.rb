# frozen_string_literal: true

RSpec.describe StringCheese::TokenBufferFormatter do
  TokenBufferManager = StringCheese::TokenBufferManager
  LabelToken = StringCheese::LabelToken
  TextToken = StringCheese::TextToken
  TokenBuffer = StringCheese::TokenBuffer
  VarToken = StringCheese::VarToken

  before(:all) do
    described_class.send(:public, *described_class.protected_instance_methods)
  end

  let(:token_buffer_manager) do
    token_buffer_manager = TokenBufferManager.new
    token_buffer_manager << VarToken.new(:var_00, '00')
    token_buffer_manager << VarToken.new(:var_01, '01')
    token_buffer_manager << VarToken.new(:var_02, '02')
    token_buffer_manager.save_buffer
    token_buffer_manager << VarToken.new(:var_10, '10')
    token_buffer_manager << VarToken.new(:var_11, '11')
    token_buffer_manager << VarToken.new(:var_12, '12')
    token_buffer_manager.save_buffer
    token_buffer_manager << VarToken.new(:var_20, '20')
    token_buffer_manager << VarToken.new(:var_21, '21')
    token_buffer_manager << VarToken.new(:var_22, '22')
    token_buffer_manager
  end
  let(:token_buffer_formatter) { described_class.new(token_buffer_manager, options) }
  let(:options) { {} }

  describe 'buffer' do
    it 'returns the buffer' do
      expect(token_buffer_formatter.buffer).to eq(token_buffer_manager.buffer)
    end
  end

  describe 'new' do
    context 'when passing a nil parameter' do
      it 'sets the token_buffer_manager' do
        expect { described_class.new(nil) }.to raise_error(ArgumentError, /Param \[token_buffer_manager\] cannot be nil/)
      end
    end

    context 'when passing the right parameter' do
      it 'sets the token_buffer_manager' do
        expect(token_buffer_formatter.token_buffer_manager).to eq(token_buffer_manager)
      end
    end
  end

  describe 'indicies_valid?' do
    context 'when the indicies are valid' do
      it 'returns true' do
        expect(token_buffer_formatter.indicies_valid?(0, 0)).to eq(true)
        expect(token_buffer_formatter.indicies_valid?(0, 1)).to eq(true)
        expect(token_buffer_formatter.indicies_valid?(0, 2)).to eq(true)
        expect(token_buffer_formatter.indicies_valid?(1, 0)).to eq(true)
        expect(token_buffer_formatter.indicies_valid?(1, 1)).to eq(true)
        expect(token_buffer_formatter.indicies_valid?(1, 2)).to eq(true)
        expect(token_buffer_formatter.indicies_valid?(2, 0)).to eq(true)
        expect(token_buffer_formatter.indicies_valid?(2, 1)).to eq(true)
        expect(token_buffer_formatter.indicies_valid?(2, 2)).to eq(true)
      end
    end

    context 'when the indicies are invalid' do
      context 'when negative' do
        it 'returns false' do
          expect(token_buffer_formatter.indicies_valid?(-1, 0)).to eq(false)
          expect(token_buffer_formatter.indicies_valid?(0, -1)).to eq(false)
          expect(token_buffer_formatter.indicies_valid?(-1, -1)).to eq(false)
        end
      end

      context 'when out of bounds' do
        it 'returns false' do
          expect(described_class.new(TokenBufferManager.new).indicies_valid?(0, 0)).to eq(false)
          expect(token_buffer_formatter.indicies_valid?(0, 3)).to eq(false)
          expect(token_buffer_formatter.indicies_valid?(2, 3)).to eq(false)
        end
      end
    end
  end

  describe 'previous_buffer_indicies' do
    context 'when passed a buffer_index == 0 and a token_index == 0' do
      it 'should not yield' do
        expect { |block| token_buffer_formatter.previous_buffer_indicies(0, 0, &block) }.not_to yield_with_args
      end
    end

    context 'when passed a buffer_index and a token_index' do
      let(:token_buffer_formatter) { described_class.new(token_buffer_manager) }
      let(:indicies) {
        [
          [[2, 2], [2, 1]],
          [[2, 1], [2, 0]],
          [[2, 0], [1, 2]],
          [[1, 1], [1, 0]],
          [[1, 0], [0, 2]],
          [[0, 2], [0, 1]],
          [[0, 1], [0, 0]],
        ]
      }

      it 'should yield the correct buffer_index and token_index' do
        indicies.each do |i|
          args, yield_args = i
          expect { |block| token_buffer_formatter.previous_buffer_indicies(args[0], args[1], &block) }.to yield_with_args(yield_args[0], yield_args[1])
        end
      end
    end
  end

  describe 'previous_token' do
    context 'when within the same buffer' do
      it 'returns the previous token' do
        expect(token_buffer_formatter.previous_token(0, 1)).to eq(token_buffer_manager.buffer[0][0])
        expect(token_buffer_formatter.previous_token(0, 2)).to eq(token_buffer_manager.buffer[0][1])
        expect(token_buffer_formatter.previous_token(1, 1)).to eq(token_buffer_manager.buffer[1][0])
        expect(token_buffer_formatter.previous_token(1, 2)).to eq(token_buffer_manager.buffer[1][1])
        expect(token_buffer_formatter.previous_token(2, 1)).to eq(token_buffer_manager.buffer[2][0])
        expect(token_buffer_formatter.previous_token(2, 2)).to eq(token_buffer_manager.buffer[2][1])
      end
    end

    context 'when traversing across buffers' do
      it 'returns the previous token' do
        expect(token_buffer_formatter.previous_token(1, 0)).to eq(token_buffer_manager.buffer[0][2])
        expect(token_buffer_formatter.previous_token(2, 0)).to eq(token_buffer_manager.buffer[1][2])
      end
    end

    context 'when there is no previous token' do
      it 'returns nil' do
        expect(token_buffer_formatter.previous_token(0, 0)).to be_nil
      end
    end

    context 'when the buffer is empty' do
      it 'returns nil' do
        expect(described_class.new(TokenBufferManager.new).previous_token(0, 0)).to be_nil
      end
    end
  end

  describe 'to_s' do
    context 'when the buffer is empty' do
      it 'returns an empty string' do
        expect(described_class.new(TokenBufferManager.new).to_s).to eq('')
      end
    end

    context 'when the buffer is not empty' do
      let(:options) { { debug: true } }
      it 'returns the formatted string' do
        expect(token_buffer_formatter.to_s).to eq('00 01 02 10 11 12 20 21 22')
      end
    end
  end
end
