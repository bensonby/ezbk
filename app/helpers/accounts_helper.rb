module AccountsHelper
  def get_account_value(amounts, account)
    account.children.reduce(0){|sum, acc| get_account_value(amounts, acc)+sum } +
    (amounts.has_key?(account.id) ? amounts[account.id]["total_amount"] : 0)
  end

  def get_saving_amount(amounts, accounts)
    - get_account_value(amounts, accounts.where(:name => 'Incomes').first) -
    get_account_value(amounts, accounts.where(:name => 'Expenses').first)
  end
end
