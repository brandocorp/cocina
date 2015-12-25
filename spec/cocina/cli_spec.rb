require 'spec_helper'

describe Cocina::CLI do
  context 'when created and run with a single dependency' do
    let(:content) { "instance 'foo' do\n  depends 'bar'\nend" }
    let(:kitchen_config) { double(Kitchen::Config) }
    let(:kitchen_instances) { double('instances') }
    let(:foo) { double('foo', name: 'foo') }
    let(:bar) { double('bar', name: 'bar') }
    let(:cli) { Cocina::CLI.new('foo') }

    before do
      allow(foo).to receive_messages(
        verify: true,
        destroy: true
      )
      allow(bar).to receive_messages(
        converge: true,
        destroy: true
      )
      allow(kitchen_instances).to receive(:get)
        .with('foo')
        .and_return(foo)
      allow(kitchen_instances).to receive(:get)
        .with('bar')
        .and_return(bar)
      allow(kitchen_config).to receive(:instances).and_return(kitchen_instances)
      allow(IO).to receive(:read).with('Cocinafile').and_return(content)
      allow(Kitchen::Config).to receive(:new).and_return(kitchen_config)
    end

    it 'parses the kitchen config' do
      expect(cli.kitchen_instance_for('foo')).to eq(foo)
      expect(cli.kitchen_instance_for('bar')).to eq(bar)
    end

    it 'stores the primary instance' do
      expect(cli.primary_instance).to eq(foo)
    end

    it 'stores the dependency instances' do
      expect(cli.dependencies).to eq([bar])
    end

    it 'converges each dependency' do
      expect(bar).to receive(:converge)
      cli.run
    end

    it 'runs verify on the primary instance' do
      expect(foo).to receive(:verify)
      cli.run
    end

    it 'destroys the instances during cleanup' do
      expect(bar).to receive(:destroy)
      expect(foo).to receive(:destroy)
      cli.run
    end
  end

  context 'when run with multiple dependencies' do
    let(:content) { "instance 'foo' do\n  depends 'baz'\n  depends 'bar'\nend" }
    let(:kitchen_config) { double(Kitchen::Config) }
    let(:kitchen_instances) { double('instances') }
    let(:foo) { double('foo', name: 'foo') }
    let(:bar) { double('bar', name: 'bar') }
    let(:baz) { double('baz', name: 'baz') }
    let(:cli) { Cocina::CLI.new('foo') }

    before do
      allow(foo).to receive_messages(
        verify: true,
        destroy: true
      )
      allow(baz).to receive_messages(
        converge: true,
        destroy: true
      )
      allow(bar).to receive_messages(
        converge: true,
        destroy: true
      )
      allow(kitchen_instances).to receive(:get)
        .with('foo')
        .and_return(foo)
      allow(kitchen_instances).to receive(:get)
          .with('baz')
          .and_return(baz)
      allow(kitchen_instances).to receive(:get)
        .with('bar')
        .and_return(bar)
      allow(kitchen_config).to receive(:instances).and_return(kitchen_instances)
      allow(IO).to receive(:read).with('Cocinafile').and_return(content)
      allow(Kitchen::Config).to receive(:new).and_return(kitchen_config)
    end

    it 'converges each dependency' do
      expect(bar).to receive(:converge)
      expect(baz).to receive(:converge)
      cli.run
    end

    it 'runs verify on the primary instance' do
      expect(foo).to receive(:verify)
      cli.run
    end

    it 'destroys the instances during cleanup' do
      expect(bar).to receive(:destroy)
      expect(baz).to receive(:destroy)
      expect(foo).to receive(:destroy)
      cli.run
    end
  end
end
