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

  describe '#actions' do
    let(:instance) { Cocina::Instance.new('foobar') }

    context 'when no actions are passed' do
      it 'has the default actions' do
        expect(instance.actions).to eq([:verify])
      end
    end

    context 'when a single action is passed' do
      it 'has the expected action list' do
        i = instance
        i.actions :foo
        expect(i.actions).to eq([:foo])
      end
    end

    context 'when multiple actions are passed' do
      context 'as an array' do
        it 'has the expected action list' do
          i = instance
          i.actions [:foo, :bar]
          expect(i.actions).to eq([:foo, :bar])
        end
      end
      context 'as an argument list' do
        it 'has the expected action list' do
          i = instance
          i.actions :foo, :bar
          expect(i.actions).to eq([:foo, :bar])
        end
      end
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

  describe '#dependencies?' do
    let(:instance) { Cocina::Instance.new('foobar') }

    it 'returns false when there are no dependencies' do
      expect(instance.dependencies?).to eq(false)
    end

    it 'returns true when there are dependencies' do
      with_dependency = instance
      with_dependency.depends 'bacon'
      expect(with_dependency.dependencies?).to be_truthy
    end
  end
end
