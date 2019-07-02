require 'Date'

class Transaction
  attr_reader :date, :action, :shares, :price
  def initialize(date, action, shares, price, fee = 0.0)
    @date = date
    @action = action
    @shares = shares
    @price = price
    @fee = fee
  end

  def cost
    @shares * @price + @fee
  end
end

transactions = [
  Transaction.new('2017-01-05', :buy, 20.0, 10.0),
  Transaction.new('2017-01-06', :buy, 20.0, 10.0),
  Transaction.new('2017-01-07', :sell, 10.0, 20.0)
]

class Record
  attr_reader :delta_acb, :delta_shares
  def initialize(delta_acb, delta_shares)
    @delta_acb = delta_acb
    @delta_shares = delta_shares
  end
end

class Context
  attr_reader :records, :acb, :share_balance
  def initialize
    @records = []
    @acb = 0.0
    @share_balance = 0.0
  end

  def add(t)
    record = build_record_from(t)
    @acb += record.delta_acb
    @share_balance += record.delta_shares
    @records << record
    self
  end

  private

    def build_record_from(t)
      if t.action == :buy
        Record.new(t.cost, t.shares)
      else
        Record.new(-1.0 * acb_per_share * t.shares, -1.0 * t.shares)
      end
    end

    def acb_per_share
      @acb / @share_balance
    end
end

acb = transactions.reduce(Context.new) { |context, t| context.add(t) }

puts "ACB = #{acb.acb}"
puts "Share balance = #{acb.share_balance}"
