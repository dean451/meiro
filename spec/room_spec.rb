require 'spec_helper'

describe Meiro::Room do
  let(:width) { 10 }
  let(:height) { 5 }

  describe '.new' do
    subject { described_class.new(width, height) }

    context '正常系' do
      context '汎用値' do
        let(:width) { 10 }
        let(:height) { 5 }

        its(:width) { should eq(10) }
        its(:height) { should eq(5) }
      end

      context '最小値' do
        let(:width) { 3 }
        let(:height) { 3 }

        its(:width) { should eq(3) }
        its(:height) { should eq(3) }
      end
    end

    context '異常系' do
      context '幅が小さすぎる場合' do
        let(:width) { 2 }

        it { expect {subject}.to raise_error }
      end

      context '高さが小さすぎる場合' do
        let(:height) { 2 }

        it { expect {subject}.to raise_error }
      end
    end
  end

  let(:room) { described_class.new(width, height) }

  let(:b_x) { 0 }
  let(:b_y) { 0 }
  let(:b_width) { 60 }
  let(:b_height) { 40 }
  let(:parent) { nil }
  let(:block) { Meiro::Block.new(b_x, b_y, b_width, b_height, parent) }

  let(:relative_x) { 8 }
  let(:relative_y) { 4 }

  describe '#x' do
    context 'Blockを紐付けていない場合' do
      subject do
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.x
      end

      it { should be_nil }
    end

    context 'Blockを紐付けている場合' do
      subject do
        room.block = block
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.x
      end

      context 'Blockのx座標が0の場合' do
        it 'Roomの相対座標がそのまま絶対座標となる' do
          should eq(8)
        end
      end

      context 'Blockのx座標が>0の場合' do
        let(:b_x) { 5 }

        it 'Blockのx座標にRoomの相対座標を足しあわせたものが絶対座標となる' do
          should eq(13)
        end
      end
    end
  end

  describe '#y' do
    context 'Blockを紐付けていない場合' do
      subject do
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.y
      end

      it { should be_nil }
    end

    context 'Blockを紐付けている場合' do
      subject do
        room.block = block
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.y
      end

      context 'Blockのx座標が0の場合' do
        it 'Roomの相対座標がそのまま絶対座標となる' do
          should eq(4)
        end
      end

      context 'Blockのx座標が>0の場合' do
        let(:b_y) { 5 }

        it 'Blockのx座標にRoomの相対座標を足しあわせたものが絶対座標となる' do
          should eq(9)
        end
      end
    end
  end

  describe '#block=' do
    subject { room.block = block }

    context '相対座標を指定していない場合' do
      it { expect{ subject }.not_to raise_error }
      it { should be_instance_of(Meiro::Block) }
    end

    context '相対座標を指定している場合' do
      let(:width)  { 5 }
      let(:height) { 5 }
      let(:b_width)  { 10 }
      let(:b_height) { 10 }

      subject do
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.block = block
      end

      [
       [1, 1],
       [1, 4],
       [4, 1],
       [4, 4],
      ].each do |x, y|
        context "適切な相対座標(#{x}, #{y})が指定されている場合" do
          let(:relative_x) { x }
          let(:relative_y) { y }

          it { expect{ subject }.not_to raise_error }
          it { should be_instance_of(Meiro::Block) }
        end
      end

      [
       [0, 0],
       [4, 0],
       [5, 1],
       [0, 4],
       [4, 5],
       [5, 4],
       [9, 9],
      ].each do |x, y|
        context "不適切な相対座標(#{x}, #{y})が指定されている場合" do
          let(:relative_x) { x }
          let(:relative_y) { y }

          it { expect{ subject }.to raise_error }
        end
      end
    end
  end

  describe '#set_random_coordinate' do
    context 'Blockを紐付けていない場合' do
      subject { room.set_random_coordinate }

      it { expect{ subject }.to raise_error }
    end

    context 'Blockを紐付けている場合' do
      subject do
        room.block = block
        room.set_random_coordinate(seed)
      end

      context 'seedが1, Blockの幅:60、高さ:40の場合' do
        let(:seed) { 1 }
        # この条件下では必ず以下の組み合わせになる
        it { should eq([38, 13]) }
      end

      context 'seedが1, Blockの幅:30、高さ:20の場合' do
        let(:seed) { 1 }
        let(:b_width) { 30 }
        let(:b_height) { 20 }
        # この条件下では必ず以下の組み合わせになる
        it { should eq([6, 12]) }
      end

      context '乱数の幅がないような設定(Blockの幅:12、高さ:7)の場合' do
        let(:width) { 10 }
        let(:height) { 5 }
        let(:seed) { 1 }
        let(:b_width) { 12 }
        let(:b_height) { 7 }

        it { should eq([1, 1]) }
      end
    end
  end

  describe '#available_x_max' do
    let(:width)  { 3 }
    let(:height) { 3 }
    let(:b_x) { 0 }
    let(:b_y) { 0 }
    let(:b_width) { 5 }
    let(:b_height) { 5 }

    subject do
      room.relative_x = 1
      room.relative_y = 1
      room.block = block
      room.available_x_max
    end

    context 'Block幅が5、Room幅が3の場合' do
      it { should eq(1) }
    end

    context 'Block幅が6、Room幅が3の場合' do
      let(:b_width) { 6 }
      it { should eq(2) }
    end
  end

  describe '#available_y_max' do
    let(:width)  { 3 }
    let(:height) { 3 }
    let(:b_x) { 0 }
    let(:b_y) { 0 }
    let(:b_width) { 5 }
    let(:b_height) { 5 }

    subject do
      room.relative_x = 1
      room.relative_y = 1
      room.block = block
      room.available_y_max
    end

    context 'Block高さが5、Room高さが3の場合' do
      it { should eq(1) }
    end

    context 'Block高さが6、Room高さが3の場合' do
      let(:b_height) { 6 }
      it { should eq(2) }
    end
  end

  describe '#each_coordinate' do
    let(:width)  { 3 }
    let(:height) { 3 }
    let(:b_x) { 0 }
    let(:b_y) { 0 }
    let(:b_width) { 5 }
    let(:b_height) { 5 }

    subject do
      room.relative_x = 1
      room.relative_y = 1
      room.block = block
      sub = []
      room.each_coordinate do |x, y|
        sub << [x, y]
      end
      sub
    end

    it do
      expected = [[1, 1], [2, 1], [3, 1],
                  [1, 2], [2, 2], [3, 2],
                  [1, 3], [2, 3], [3, 3],]
      should eq(expected)
    end
  end
end