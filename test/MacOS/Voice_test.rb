require_relative '../helper'
require 'MacOS/Voice'

describe MacOS::Voice do
  def with_voices(&block)
    MacOS::Voice.stub(:`, fixture('say-v.txt'), &block)
  end

  def voice(name)
    MacOS::Voice.list.find{|voice| voice.name == name}
  end

  it "makes one for each voice say knows" do
    with_voices do
      _(MacOS::Voice.all.size).must_equal(8)
      _(MacOS::Voice.list.map(&:name)).must_include('Albert')
    end
  end

  it "reads a voice's name, localisation and description" do
    with_voices do
      albert = voice('Albert')
      _(albert.localization).must_equal('en_US')
      _(albert.description).must_equal('Hello! My name is Albert.')
    end
  end

  it "reads a name with spaces in it whole" do
    with_voices do
      _(voice('Bad News').localization).must_equal('en_US')
      _(voice('Eddy (English (UK))').localization).must_equal('en_GB')
    end
  end

  it "gives a description without its newline" do
    with_voices do
      _(MacOS::Voice.list.none?{|voice| voice.description.end_with?("\n")}).must_equal(true)
    end
  end

  it "picks a voice at random from those say knows" do
    with_voices do
      _(MacOS::Voice.list.map(&:name)).must_include(MacOS::Voice.random_voice.name)
    end
  end
end
