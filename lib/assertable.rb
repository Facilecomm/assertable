# frozen_string_literal: true

require 'assertable/version'

module Assertable
  class Assertion < RuntimeError; end
  class BadAssertionChoice < RuntimeError; end

  private

  def assert_send(method_name)
    assert(
      send(method_name),
      "Expected :#{method_name} to not be falsy, but it was."
    )
  end

  def assert(value_to_check, message = nil)
    return if value_to_check

    message ||= "Expected #{value_to_check.inspect} to be truthy."
    raise Assertion, message
  end

  def assert_equal(expected_value, actual_value, message = nil)
    if expected_value.nil?
      raise BadAssertionChoice, 'Use assert_nil when expecting nil'
    end
    return if expected_value == actual_value

    message ||= [
      "Expected: #{expected_value.inspect}",
      "Actual: #{actual_value.inspect}"
    ].join("\n")
    raise Assertion, message
  end

  def assert_includes(ok_values, value, message = nil)
    unless ok_values.is_a? Array
      raise BadAssertionChoice, 'Use assert_equal if checking equality'
    end
    return if ok_values.include? value

    message ||= [
      value,
      'is not included in',
      ok_values.map(&:to_s).join(',')
    ].join ' '
    raise Assertion, message
  end

  def assert_kind_of(klass, object, message = nil)
    return if object.is_a?(klass)

    message ||= "Expected #{object.inspect} to be a #{klass}. But it was not."
    raise Assertion, message
  end

  def assert_nil(value_to_check, message = nil)
    return if value_to_check.nil?

    message ||= "Expected #{value_to_check.inspect} to be nil."
    raise Assertion, message
  end

  def refute(value_to_check, message = nil)
    return unless value_to_check

    message ||= "Expected #{value_to_check.inspect} to be falsy."
    raise Assertion, message
  end

  def refute_equal(expected_value, actual_value, message = nil)
    return unless expected_value == actual_value

    message ||= [
      "Expected #{actual_value.inspect} to not be equal to",
      "#{expected_value.inspect}."
    ].join(' ')
    raise Assertion, message
  end
end
