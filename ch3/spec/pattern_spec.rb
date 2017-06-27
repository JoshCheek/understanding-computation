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

  xspecify 'empty regex matches an empty string' do
    match! //, ''
    no_match! /a/, ''
    no_match! //, 'a'
  end

  it 'matches sequences' do
    match!    /abc/, "abc"
    no_match! /abc/, "acb"
    no_match! /abc/, "abbc"
  end

  it 'matches optionals' do
    match! /ab?c/, "ac"
    match! /ab?c/, "abc"
    no_match! /ab?c/, "axc"
    no_match! /ab?c/, "abbc"
  end

  it 'matches zero or more' do
    match! /ab*c/, "ac"
    match! /ab*c/, "abc"
    match! /ab*c/, "abbc"
    no_match! /ab*c/, "axc"
  end

  it 'matches one or more' do
    no_match! /ab+c/, "ac"
    match!    /ab+c/, "abc"
    match!    /ab+c/, "abbc"
    no_match! /ab+c/, "axc"
  end

  it 'matches eithers' do
    match! /a(b|c)d/, "abd"
    match! /a(b|c)d/, "acd"
    no_match! /a(b|c)d/, "axd"
    no_match! /a(b|c)d/, "abcd"
  end

  it 'matches more complex shit' do
    match! /a(bc|de|fg|hi*)j?k/, "abcjk"
    match! /a(bc|de|fg|hi*)j?k/, "adejk"
    match! /a(bc|de|fg|hi*)j?k/, "afgjk"
    match! /a(bc|de|fg|hi*)j?k/, "ahijk"
    match! /a(bc|de|fg|hi*)j?k/, "ahk"
    match! /a(bc|de|fg|hi*)j?k/, "ahiiik"
    match! /a(bc|de|fg|hi*)j?k/, "ahiiijk"
    match! /a(bc|de|fg|hi*)j?k/, "ahk"
    no_match! /a(bc|de|fg|hi*)j?k/, "aik"
    no_match! /a(bc|de|fg|hi*)j?k/, "abk"
    no_match! /a(bc|de|fg|hi*)j?k/, "abhk"
    no_match! /a(bc|de|fg|hi*)j?k/, "ahjjk"
    no_match! /a(bc|de|fg|hi*)j?k/, "xbcjk"
    no_match! /a(bc|de|fg|hi*)j?k/, "abcjx"
    no_match! /a(bc|de|fg|hi*)j?k/, "abcxk"
  end
end
