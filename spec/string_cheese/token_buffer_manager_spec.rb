# frozen_string_literal: true

RSpec.describe StringCheese::TokenBufferManager do
  LabelToken = StringCheese::LabelToken
  TextToken = StringCheese::TextToken
  TokenBuffer = StringCheese::TokenBuffer
  VarToken = StringCheese::VarToken

  let(:buffer_manager) { described_class.new }
  let(:token_buffer) { TokenBuffer.new }
  let(:token) { TextToken.new('token') }

  describe 'new' do
    it 'initializes the buffer and sets the buffer index' do
      expect(buffer_manager.send(:buffer)).to eq([])
      expect(buffer_manager.buffer_index).to eq(-1)
    end
  end

  describe '<<' do
    context 'when a non-token object is pushed' do
      let(:token) { :not_a_token }

      it 'raises an error' do
        expect { buffer_manager << token }.to raise_error(ArgumentError, /Param \[token\] is not a Token/)
      end
    end

    context 'when a token is pushed' do
      it 'token is added to the buffer' do
        expect(buffer_manager << token).to eq([token])
      end
    end

    describe 'any?' do
      it 'returns false if buffer is empty' do
        expect(buffer_manager.any?).to eq(false)
      end

      it 'returns true if buffer is not empty' do
        buffer_manager << token
        expect(buffer_manager.any?).to eq(true)
      end
    end

    describe 'clear_buffer' do
      it 'clears the buffer' do
        buffer_manager << token
        expect(buffer_manager.any?).to eq(true)
        buffer_manager.clear_buffer
        expect(buffer_manager.any?).to eq(false)
      end
    end

    describe 'current_buffer' do
      context 'when the buffer is empty' do
        it 'returns an empty Array' do
          expect(buffer_manager.current_buffer).to eq([])
        end
      end

      context 'when the buffer is not empty' do
        let(:token2) { TextToken.new('token2') }
        let(:token3) { TextToken.new('token3') }
        let(:token4) { TextToken.new('token4') }

        it 'returns the current_buffer' do
          buffer_manager << token
          buffer_manager << token2
          buffer_manager << token3
          buffer_manager << token4
          expect(buffer_manager.current_buffer).to eq([token, token2, token3, token4])
        end
      end
    end

    describe 'update_current!' do
      context 'when updating the current buffer' do
        let(:var_1) { VarToken.new(:var_1, 1) }
        let(:var_2) { VarToken.new(:var_2, 2) }
        let(:var_1_label) { LabelToken.new(:var_1_label, :var_1) }
        let(:var_2_label) { LabelToken.new(:var_2_label, :var_2) }

        let(:vars_and_labels) {
          [var_1, var_2, var_1_label, var_2_label]
        }

        let(:update_vars) { var_1.to_h.merge(var_2.to_h) }
        let(:update_labels) { var_1_label.to_h.merge(var_2_label.to_h) }

        it 'updates the current buffer' do
          buffer_manager << var_1
          buffer_manager << var_2
          buffer_manager << var_1_label
          buffer_manager << var_2_label
          expect(buffer_manager.current_buffer).to include(var_1, var_2, var_1_label, var_2_label)
          expect(buffer_manager.current_buffer.map { |t| "#{t.key}#{t.value}"} ==
                 vars_and_labels.map { |t| "#{t.key}#{t.value}"}).to eq(true)
          var_1.value = 11
          var_2.value = 22
          var_1_label.value = 'New Var 1 Label'
          var_2_label.value = 'New Var 2 Label'
          buffer_manager.update_current!(update_vars.merge(update_labels))
          expect(buffer_manager.current_buffer.map { |t| "#{t.key}#{t.value}"} ==
                 vars_and_labels.map { |t| "#{t.key}#{t.value}"}).to eq(true)
        end
      end
    end
  end

  describe 'any?' do
    context 'when the buffer is empty' do
      it 'returns false' do
        expect(buffer_manager.any?).to eq(false)
      end
    end

    context 'when the buffer is not empty' do
      it 'returns true' do
        buffer_manager << LabelToken.new(:dummy_label, :dummy_var)
        expect(buffer_manager.any?).to eq(true)
      end
    end
  end

  describe 'clear_buffer' do
    context 'when the buffer is empty' do
      it 'clears the buffer' do
        expect { buffer_manager.clear_buffer }.to_not raise_error
        expect(buffer_manager.send(:buffer)).to eq([])
        expect(buffer_manager.buffer_index).to eq(-1)
      end
    end

    context 'when the buffer is not empty' do
      it 'clears the buffer'
    end
  end

  describe 'current_buffer' do
    context 'when the buffer is empty' do
      it 'returns an empty array' do
        expect(buffer_manager.current_buffer).to eq([])
      end
    end

    context 'when the buffer has one token buffer' do
      let(:token_buffer) { TextToken.new('dummy') }

      it 'returns the buffer' do
        token_buffer << token
        buffer_manager << token_buffer
        expect(buffer_manager.current_buffer).to eq(token_buffer)
      end
    end

    context 'when the buffer has more than one token buffer' do
      let(:token1) { VarToken.new(:var_1, 1) }
      let(:token2) { VarToken.new(:var_2, 2) }

      it 'returns the buffer' do
        # Token buffer 1
        buffer_manager << token1
        expect(buffer_manager.current_buffer[0]).to eq(token1)
        # Token buffer 2
        buffer_manager.save_buffer # save the buffer
        buffer_manager << token2
        expect(buffer_manager.current_buffer[0]).to eq(token2)
      end
    end
  end

  describe 'empty?' do
    context 'when the buffer is empty' do
      it 'returns true' do
        expect(buffer_manager.empty?).to eq(true)
      end
    end

    context 'when the buffer is not empty' do
      it 'returns false' do
        buffer_manager << LabelToken.new(:dummy_label, :dummy_var)
        expect(buffer_manager.empty?).to eq(false)
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
        token_buffer = []
        # 0
        token_buffer << TokenBuffer.new
        token_buffer[0] << TextToken.new('0, 0')
        token_buffer[0] << TextToken.new('0, 1')
        token_buffer[0] << TextToken.new('0, 2')
        # 1
        token_buffer << TokenBuffer.new
        token_buffer[1] << TextToken.new('1, 0')
        token_buffer[1] << TextToken.new('1, 1')
        token_buffer[1] << TextToken.new('1, 2')
        # 2
        token_buffer << TokenBuffer.new
        token_buffer[2] << TextToken.new('2, 0')
        token_buffer[2] << TextToken.new('2, 1')
        token_buffer[2] << TextToken.new('2, 2')
        # Assign the buffer
        buffer_manager.send(:buffer=, token_buffer)

        indicies.each do |i|
          args = i[0]
          yield_args = i[1]
          puts "Testing args: #{args}, yield_args: #{yield_args}"
          expect { |block| buffer_manager.send(:previous_buffer_indicies, args[0], args[1], &block) }.to yield_with_args(yield_args[0], yield_args[1])
        end
      end
    end
  end
end
