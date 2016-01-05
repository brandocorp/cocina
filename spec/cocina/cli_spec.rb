require 'spec_helper'

describe Cocina::CLI do
  let(:logger) do
    Kitchen::Logger.new(level: Logger::FATAL)
  end

  before do
    allow(Kitchen::Logger).to receive(:new)
      .with(stdout: STDOUT, color: :white, progname: 'Cocina')
      .and_return(logger)
  end

  context 'when created and run with a single dependency' do
    let(:content) do
      "".tap do |cfg|
        cfg << "instance 'foo' do\n"
        cfg << "  depends 'bar'\n"
        cfg << "  actions :create, :converge, :verify, :destroy\n"
        cfg << "  cleanup true\n"
        cfg << "end"
      end
    end
    let(:kitchen_config) { double(Kitchen::Config) }
    let(:kitchen_instances) { double('instances') }
    let(:foo) { double('foo', name: 'foo') }
    let(:bar) { double('bar', name: 'bar') }
    let(:cli) { Cocina::CLI.new('foo') }

    before do
      allow(foo).to receive_messages(
        create: true,
        converge: true,
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
      allow(IO).to receive(:read).with('Cocinafile').and_return(content)
      allow(Kitchen::Config).to receive(:new).and_return(kitchen_config)
    end

    it 'stores the primary instance' do
      primary = cli.primary_instance
      expect(primary).to be_a(Cocina::Instance)
      expect(primary.name).to eq('foo')
    end

    it 'stores the primary dependencies' do
      expect(cli.primary_dependencies).to eq(['bar'])
    end

    it 'converges each dependency' do
      expect(bar).to receive(:converge)
      cli.run
    end

    it 'runs all actions on the primary instance' do
      expect(foo).to receive(:create)
      expect(foo).to receive(:converge)
      expect(foo).to receive(:verify)
      expect(foo).to receive(:destroy)
      cli.run
    end

    it 'destroys the instances during cleanup' do
      expect(bar).to receive(:destroy)
      expect(foo).to receive(:destroy)
      cli.run
    end
  end

  context 'when run with multiple dependencies' do
    let(:content) do
      "".tap do |cfg|
        cfg << "instance 'foo' do\n"
        cfg << "  depends 'baz'\n"
        cfg << "  depends 'bar'\n"
        cfg << "  cleanup true\n"
        cfg << "end"
      end
    end
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
      allow(kitchen_config).to receive(:log_level=).and_return(true)
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

  context 'with nested dependencies' do
    let(:content) do
      String.new.tap do |cfg|
        cfg << "instance 'foo' do\n"
        cfg << " depends 'bar'\n"
        cfg << " cleanup true\n"
        cfg << "end\n\n"
        cfg << "instance 'bar' do\n"
        cfg << " depends 'baz'\n"
        cfg << "end\n"
      end
    end
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
      allow(kitchen_config).to receive(:log_level=).and_return(true)
      allow(IO).to receive(:read).with('Cocinafile').and_return(content)
      allow(Kitchen::Config).to receive(:new).and_return(kitchen_config)
    end

    it 'converges direct dependencies' do
      expect(bar).to receive(:converge)
      cli.run
    end

    it 'converges upstream dependencies' do
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
