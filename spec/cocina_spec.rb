require 'spec_helper'

describe Cocina do
  it 'has a version number' do
    expect(Cocina::VERSION).not_to be nil
  end

  describe '.version' do
    it 'returns the version number' do
      expect(Cocina.version).to eq('0.1.0')
    end
  end
end
