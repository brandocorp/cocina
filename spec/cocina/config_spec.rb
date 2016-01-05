require 'spec_helper'

shared_context 'kitchen config' do
  let(:kitchen_config) { double(Kitchen::Config) }
  let(:kitchen_instances) { double('instances') }
  let(:foo) { double('foo', name: 'foo') }
  let(:bar) { double('bar', name: 'bar') }

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
    allow(kitchen_config).to receive(:log_level=).and_return(true)
    allow(Kitchen::Config).to receive(:new).and_return(kitchen_config)
  end
end

describe Cocina::Config do
  context 'when creating a new config' do
    context 'with no instance configuration' do
      let(:config) { Cocina::Config.new('foobar') }

      before do
        allow(IO).to receive(:read).with('foobar').and_return('')
      end

      it 'reads configuration from a file' do
        expect(config.cocinafile).to eq('foobar')
      end

      it 'has an empty instance list' do
        expect(config.instances).to eq([])
      end
    end

    context 'with instance configuration' do
      let(:content) { "instance 'foo' do\n  depends 'bar'\nend" }
      let(:config) { Cocina::Config.new('foobar') }
      let(:baz) { double('baz', name: 'baz') }

      include_context 'kitchen config'

      before do
        allow(IO).to receive(:read).with('foobar').and_return(content)
      end

      it 'has the correct instance list' do
        instances = config.instances
        first = instances.first
        expect(instances.length).to eq(2)
        expect(first.name).to eq('foo')
      end

      it 'exposes the instances' do
        instance = config['foo']
        expect(instance).to be_a(Cocina::Instance)
        expect(instance.name).to eq('foo')
        expect(instance.dependencies).to eq(['bar'])
      end
    end

    context 'with nested dependencies' do
      let(:content) do
        String.new.tap do |cfg|
          cfg << "instance 'foo' do\n depends 'bar'\nend\n"
          cfg << "instance 'bar' do\n depends 'baz'\nend\n"
        end
      end
      let(:config) { Cocina::Config.new('foobar') }
      let(:baz) { double('baz', name: 'baz') }

      include_context 'kitchen config'

      before do
        allow(baz).to receive_messages(
          converge: true,
          destroy: true
        )
        allow(kitchen_instances).to receive(:get)
          .with('baz')
          .and_return(baz)
        allow(IO).to receive(:read).with('foobar').and_return(content)
      end

      it 'has the correct instance list' do
        instances = config.instances
        expect(instances.length).to eq(3)
        expect(instances.map(&:name)).to eq(['foo', 'bar', 'baz'])
      end
    end
  end
end
