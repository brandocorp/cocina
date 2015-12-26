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

  describe '#depends' do
    let(:instance) do
      i = Cocina::Instance.new('foobar')
      i.depends 'foo'
      i.depends 'bar'
      i
    end

    it 'adds a dependency' do
      expect(instance.dependencies).to eq(['foo', 'bar'])
    end
  end

  describe '#runner' do
    let(:instance) { Cocina::Instance.new('foobar') }
    let(:runner) { double('runner', destroy: "destroy", converge: "converge") }

    before do
      instance.runner = runner
    end

    it 'delegates to the kitchen instance' do
      expect(runner).to receive(:destroy)
      expect(runner).to receive(:converge)
      expect(instance.destroy).to eq('destroy')
      expect(instance.converge).to eq('converge')
    end
  end

  describe '#has_dependency?' do
    let(:instance) { Cocina::Instance.new('foobar') }

    it 'returns false when there are no dependencies' do
      expect(instance.has_dependency?).to eq(false)
    end

    it 'returns true when there are dependencies' do
      with_dependency = instance
      with_dependency.depends 'bacon'
      expect(with_dependency.has_dependency?).to be_truthy
    end
  end
end
