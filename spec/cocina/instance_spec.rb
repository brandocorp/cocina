require 'spec_helper'

describe Cocina::Instance do
  describe '.new' do
    let(:instance) { Cocina::Instance.new('foobar') }

    it 'has no dependencies' do
      expect(instance.dependencies).to be_empty
    end
  end

  describe '#name' do
    let(:instance) { Cocina::Instance.new('foobar') }

    it 'returns the instance name' do
      expect(instance.name).to eq('foobar')
    end
  end

  describe '#depends_on' do
    let(:instance) do
      i = Cocina::Instance.new('foobar')
      i.depends_on 'foo'
      i.depends_on 'bar'
      i
    end

    it 'adds a dependency' do
      expect(instance.dependencies).to eq(['foo', 'bar'])
    end
  end
end
