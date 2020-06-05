# frozen_string_literal: true

require 'test_helper'

class AssertableTest < Minitest::Test
  ###################################################
  #                Toy klasses
  ###################################################

  class FakeDonut
    include Assertable

    attr_reader :price_cents, :sold, :damaged, :discount_cents

    def initialize(price_cents: nil)
      @price_cents = price_cents
      @sold = false
      @damaged = nil
      assert_nil @damaged
    end

    def sell
      assert price_cents
      assert_nil damaged
      @sold = true
    end

    def discount
      assert_equal price_cents, actual_price_cents
      @discount_cents = price_cents * 0.1
    end

    def actual_price_cents
      price_cents - discount_cents.to_i
    end

    def take_a_bite
      @damaged = true
    end

    def repair_donut
      @damaged = false
    end
  end

  class FakePancake
    include Assertable

    attr_reader :celsus_temperature, :served

    def initialize(celsus_temperature: 5)
      @celsus_temperature = celsus_temperature
      @served = nil
      assert(
        celsus_temperature > 0,
        'temperature must be positive'
      )
    end

    def warm_up
      @celsus_temperature = 50
      check_warm
    end

    def serve
      assert_nil served, 'Already served!'
      check_warm
      @served = true
    end

    private

    def check_warm
      assert_equal(
        50,
        celsus_temperature,
        'Not at correct serving temperature'
      )
    end
  end

  class FakeDuck
    include Assertable

    def initialize
      @quacked = nil
    end

    def quack
      assert_equal nil, @quacked
    end
  end

  class FakePiggyBank
    include Assertable

    def initialize(coin_capacity:)
      @coin_capacity = coin_capacity
      @coin_count = 0
    end

    def add_coin
      refute full?
      @coin_count += 1
    end

    def retrieve_coin
      refute empty?, 'Sorry I am empty :('
      @coin_count -= 1
      :coin
    end

    private

    attr_reader :coin_capacity, :coin_count

    def full?
      coin_count >= coin_capacity
    end

    def empty?
      coin_count <= 0
    end
  end

  class FakeVendingMachine
    include Assertable

    def initialize(units:)
      @units = units
      refute_equal nil, units
    end

    def push_button
      refute_equal 0, units
      @units -= 1
      :coke
    end

    private

    attr_reader :units
  end

  class FakeChicken
    include Assertable

    def initialize(age_in_days:)
      @age_in_days = age_in_days
      assert_send :age_in_days
    end

    private

    attr_reader :age_in_days
  end

  class FakeCar
    include Assertable

    SUPPORTED_MAKERS = %i[
      Citroën
      Opel
    ].freeze

    DEFAULT_GEARS = %i[
      first
      second
      third
    ].freeze

    def initialize(maker, gears: DEFAULT_GEARS)
      assert_includes SUPPORTED_MAKERS, maker

      @maker = maker
      @gears = gears
    end

    def change_gear(gear)
      assert_includes gears, gear
    end

    private

    attr_reader :maker, :gears
  end

  class FakeKlassFilter
    include Assertable

    def initialize(filtered_klass:)
      @filtered_klass = filtered_klass
    end

    def call(candidate)
      assert_kind_of filtered_klass, candidate
    end

    private

    attr_reader :filtered_klass
  end

  ###################################################
  #                Tests start here
  ###################################################

  def test_that_it_has_a_version_number
    refute_nil ::Assertable::VERSION
  end

  def test_assert_raises_value_is_not_truthy
    error = assert_raises Assertable::Assertion do
      donut.sell
    end
    assert_equal(
      'Expected nil to be truthy.',
      error.message
    )
    refute donut.sold
  end

  def test_assert_does_not_raise_whenever_value_is_truthy
    assert_nothing_raised do
      priced_donut.sell
    end
    assert priced_donut.sold
  end

  def test_assert_nil_does_not_raise_whenever_value_is_nil
    assert_nothing_raised do
      priced_donut.sell
    end
    assert priced_donut.sold
  end

  def test_assert_nil_raises_whenever_value_is_truthy
    priced_donut.take_a_bite
    error = assert_raises Assertable::Assertion do
      priced_donut.sell
    end
    assert_equal(
      'Expected true to be nil.',
      error.message
    )
    refute priced_donut.sold
  end

  def test_assert_nil_raises_whenever_value_is_false
    priced_donut.take_a_bite
    priced_donut.repair_donut
    error = assert_raises Assertable::Assertion do
      priced_donut.sell
    end
    assert_equal(
      'Expected false to be nil.',
      error.message
    )
    refute priced_donut.sold
  end

  def test_assert_equal_raises_iff_actual_value_does_not_match_expected_value
    priced_donut
    assert_nothing_raised do
      priced_donut.discount
    end
    error = assert_raises Assertable::Assertion do
      priced_donut.discount
    end
    assert_equal(
      [
        'Expected: 100',
        'Actual: 90'
      ].join("\n"),
      error.message
    )
  end

  def test_can_override_assert_equal_message
    error = assert_raises Assertable::Assertion do
      pancake.serve
    end
    assert_equal(
      'Not at correct serving temperature',
      error.message
    )
  end

  def test_can_override_assert_message
    error = assert_raises Assertable::Assertion do
      FakePancake.new celsus_temperature: -18
    end
    assert_equal(
      'temperature must be positive',
      error.message
    )
  end

  def test_can_override_assert_nil_message
    pancake.warm_up
    pancake.serve
    error = assert_raises Assertable::Assertion do
      pancake.serve
    end
    assert_equal(
      'Already served!',
      error.message
    )
  end

  def test_advised_to_use_assert_nil_whenever_relevant
    error = assert_raises Assertable::BadAssertionChoice do
      FakeDuck.new.quack
    end
    assert_equal(
      'Use assert_nil when expecting nil',
      error.message
    )
  end

  def test_refute
    piggy_bank = FakePiggyBank.new(coin_capacity: 2)
    assert_nothing_raised do
      piggy_bank.add_coin
      piggy_bank.add_coin
    end
    error = assert_raises Assertable::Assertion do
      piggy_bank.add_coin
    end
    assert_equal(
      'Expected true to be falsy.',
      error.message
    )
  end

  def test_refute_with_message
    piggy_bank = FakePiggyBank.new(coin_capacity: 2)
    assert_nothing_raised do
      piggy_bank.add_coin
    end
    assert_equal :coin, piggy_bank.retrieve_coin
    error = assert_raises Assertable::Assertion do
      piggy_bank.retrieve_coin
    end
    assert_equal(
      'Sorry I am empty :(',
      error.message
    )
  end

  def test_refute_equal_is_silent_when_it_should_be
    assert_equal :coke, vending_maching.push_button
  end

  def test_refute_equal_raises_when_equal
    error = assert_raises Assertable::Assertion do
      FakeVendingMachine.new(units: 0).push_button
    end
    assert_equal(
      'Expected 0 to not be equal to 0.',
      error.message
    )
  end

  def test_refute_equal_can_have_nil_comparison
    error = assert_raises Assertable::Assertion do
      FakeVendingMachine.new(units: nil)
    end
    assert_equal(
      'Expected nil to not be equal to nil.',
      error.message
    )
  end

  def test_assert_send_raises_when_method_returns_nil
    error = assert_raises do
      FakeChicken.new(age_in_days: nil)
    end
    assert_equal(
      'Expected :age_in_days to not be falsy, but it was.',
      error.message
    )
  end

  def test_assert_send_raises_when_method_returns_false
    error = assert_raises do
      FakeChicken.new(age_in_days: false)
    end
    assert_equal(
      'Expected :age_in_days to not be falsy, but it was.',
      error.message
    )
  end

  def test_assert_send_does_not_when_method_returns_something_truthy
    assert_nothing_raised do
      FakeChicken.new(age_in_days: 100)
    end
  end

  def test_assert_includes_is_silent_when_value_in_ok_values
    assert_nothing_raised do
      FakeCar.new :Opel
    end
  end

  def test_assert_includes_raises_when_value_is_not_in_ok_values
    error = assert_raises Assertable::Assertion do
      FakeCar.new :Porsche
    end
    assert_equal(
      'Porsche is not included in Citroën,Opel',
      error.message
    )
  end

  def test_assert_includes_raises_when_ok_values_is_not_a_list
    car = FakeCar.new :Citroën, gears: :first
    error = assert_raises Assertable::BadAssertionChoice do
      car.change_gear :first
    end
    assert_equal(
      'Use assert_equal if checking equality',
      error.message
    )
  end

  def test_assert_kind_of_raises_when_not_of_given_klass
    filter = FakeKlassFilter.new(filtered_klass: FakeDonut)

    object = Object.new

    error = assert_raises Assertable::Assertion do
      filter.call object
    end
    assert_equal(
      [
        "Expected #{object.inspect} to be a AssertableTest::FakeDonut.",
        'But it was not.'
      ].join(' '),
      error.message
    )
  end

  class FakeElectricDuck < FakeDuck; end

  def test_assert_kind_of_does_not_raise_when_object_is_of_that_klass
    filter = FakeKlassFilter.new(filtered_klass: FakeDuck)

    assert_nothing_raised do
      filter.call FakeElectricDuck.new
    end
  end

  private

  def donut
    @donut ||= FakeDonut.new
  end

  def priced_donut
    @priced_donut ||= FakeDonut.new price_cents: 100
  end

  def pancake
    @pancake ||= FakePancake.new
  end

  def vending_maching
    @vending_maching ||= FakeVendingMachine.new units: 200
  end

  # Point of the method is to make the purpose of test clearer
  # But it is better to let it raise
  def assert_nothing_raised
    yield
  end
end
