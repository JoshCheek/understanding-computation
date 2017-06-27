require 'pattern'
require 'spec_helper'

RSpec.describe 'Pattern' do
  def match!(regex, str)
    pattern = Pattern.new(regex)
    match   = pattern.match(str)
    expect(match).to be_a_kind_of Pattern::Match
  end

  def no_match!(regex, str)
    pattern = Pattern.new(regex)
    match   = pattern.match(str)
    expect(match).to eq nil
  end

  it 'returns a match object or nil based on whether it matches' do
    match!    /a/, "a"
    no_match! /a/, "b"
  end
end
