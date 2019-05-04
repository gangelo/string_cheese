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
    token_buffer_manager << VarToken.new(:var_1, 1)
    token_buffer_manager << VarToken.new(:var_2, 2)
    token_buffer_manager.save_buffer
    token_buffer_manager << VarToken.new(:var_3, 3)
    token_buffer_manager << VarToken.new(:var_4, 4)
    token_buffer_manager
  end
  let(:token_buffer_formatted) { described_class.new(token_buffer_manager) }

  describe 'buffer' do
    it 'returns the buffer' do
      expect(token_buffer_formatted.buffer).to eq(token_buffer_manager)
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
        expect(token_buffer_formatted.token_buffer_manager).to eq(token_buffer_manager)
      end
    end
  end

  describe 'indicies_valid?' do
    context 'when the indicies are valid' do
      it 'returns true' do
        expect(token_buffer_formatted.indicies_valid?(0, 0)).to eq(true)
        expect(token_buffer_formatted.indicies_valid?(0, 1)).to eq(true)
        expect(token_buffer_formatted.indicies_valid?(1, 0)).to eq(true)
        expect(token_buffer_formatted.indicies_valid?(1, 1)).to eq(true)
      end
    end

    context 'when the indicies are invalid' do
      context 'when negative' do
        it 'returns false' do
          expect(token_buffer_formatted.indicies_valid?(-1, 0)).to eq(false)
          expect(token_buffer_formatted.indicies_valid?(0, -1)).to eq(false)
          expect(token_buffer_formatted.indicies_valid?(-1, -1)).to eq(false)
        end
      end

      context 'when out of bounds' do
        it 'returns false' do
          expect(described_class.new(TokenBufferManager.new).indicies_valid?(0, 0)).to eq(false)
          expect(token_buffer_formatted.indicies_valid?(0, 2)).to eq(false)
          expect(token_buffer_formatted.indicies_valid?(1, 2)).to eq(false)
        end
      end
    end
  end

  describe 'previous_token' do
    context 'when within the same buffer' do
      it 'returns the previous token' do
        expect(token_buffer_formatted.previous_token(0, 1)).to eq(token_buffer_manager.buffer[0][0])
        expect(token_buffer_formatted.previous_token(1, 1)).to eq(token_buffer_manager.buffer[1][0])
      end
    end

    context 'when traversing across buffers' do
      it 'returns the previous token' do
        expect(token_buffer_formatted.previous_token(1, 0)).to eq(token_buffer_manager.buffer[0][1])
      end
    end

    context 'when there is no previous token' do
      it 'returns nil' do
        expect(token_buffer_formatted.previous_token(0, 0)).to be_nil
      end
    end

    context 'when the buffer is empty' do
      it 'returns nil' do
        expect(described_class.new(TokenBufferManager.new).previous_token(0, 0)).to be_nil
      end
    end
  end

  describe 'previous_buffer_indicies' do
    context 'when passed a buffer_index == 0 and a token_index == 0' do
      it 'should not yield' do
        expect { |block| buffer_manager.send(:previous_buffer_indicies, 0, 0, &block) }.not_to yield_with_args
      end
    end

    context 'when passed a buffer_index and a token_index' do
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
        # 0
        buffer_manager << TextToken.new('0, 0')
        buffer_manager << TextToken.new('0, 1')
        buffer_manager << TextToken.new('0, 2')
        buffer_manager.save_buffer
        # 1
        buffer_manager << TextToken.new('1, 0')
        buffer_manager << TextToken.new('1, 1')
        buffer_manager << TextToken.new('1, 2')
        buffer_manager.save_buffer
        # 2
        buffer_manager << TextToken.new('2, 0')
        buffer_manager << TextToken.new('2, 1')
        buffer_manager << TextToken.new('2, 2')

        indicies.each do |i|
          args = i[0]
          yield_args = i[1]
          expect { |block| buffer_manager.send(:previous_buffer_indicies, args[0], args[1], &block) }.to yield_with_args(yield_args[0], yield_args[1])
        end
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
      it 'returns the formatted string' do
        expect(token_buffer_formatted.to_s).to eq('1 2 3 4')
      end
    end
  end
end
