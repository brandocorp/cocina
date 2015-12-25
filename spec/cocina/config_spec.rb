require 'spec_helper'

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
      let(:content) { "instance 'foo' do\n  depends_on 'bar'\nend" }
      let(:config) { Cocina::Config.new('foobar') }

      before do
        allow(IO).to receive(:read).with('foobar').and_return(content)
      end

      it 'has the correct instance list' do
        expect(config.instances.length).to eq(1)
        expect(config.instances.first.name).to eq('foo')
      end

    end
  end
end
