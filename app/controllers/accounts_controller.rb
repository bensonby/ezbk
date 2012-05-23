class AccountsController < ApplicationController
  before_filter :require_user
  before_filter :require_accounts
  before_filter :set_page_name

  def set_page_name
    @page_name = "accounts"
  end

  def autocomplete_account_name
    @return_list = current_user_accounts.where("name like '%" + params[:term] + "%'").map do |a|
      {:id => a.id, :value => a.name}
    end
    render :json => @return_list
  end

  def require_accounts
    if current_user_accounts.blank?
      create_default
      return true
    end
  end

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = current_user_accounts
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @account = current_user_accounts.find(params[:id])
    @transactions = @account.transactions.order("transaction_date DESC, id DESC")

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.json
  def new
    @account = Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = current_user_accounts.find(params[:id])
  end

  def create_default
    assets = current_user.accounts.build({:name => 'Assets'})
    assets.save!
      bank_account = current_user.accounts.build({:name => 'Bank Account', :parent_id => assets.id}).save!
      cash = current_user.accounts.build({:name => 'Cash', :parent_id => assets.id}).save!
      octopus = current_user.accounts.build({:name => 'Octopus', :parent_id => assets.id}).save!
      receivables = current_user.accounts.build({:name => 'Receivables/Payable', :parent_id => assets.id})
      receivables.save!
        someone = current_user.accounts.build({:name => 'Someone', :parent_id => receivables.id}).save!
    equities = current_user.accounts.build({:name => 'Equities'})
    equities.save!
    expenses = current_user.accounts.build({:name => 'Expenses'})
    expenses.save!
      family = current_user.accounts.build({:name => 'Family', :parent_id => expenses.id}).save!
      food = current_user.accounts.build({:name => 'Food', :parent_id => expenses.id})
      food.save!
        breakfast = current_user.accounts.build({:name => 'Breakfast', :parent_id => food.id}).save!
        dinner = current_user.accounts.build({:name => 'Dinner', :parent_id => food.id}).save!
        lunch = current_user.accounts.build({:name => 'Lunch', :parent_id => food.id}).save!
        snacks = current_user.accounts.build({:name => 'Snacks and Drinks', :parent_id => food.id}).save!
      medical = current_user.accounts.build({:name => 'Medical', :parent_id => expenses.id}).save!
      misc = current_user.accounts.build({:name => 'Misc', :parent_id => expenses.id}).save!
      recreation = current_user.accounts.build({:name => 'Recreation', :parent_id => expenses.id}).save!
      transportation = current_user.accounts.build({:name => 'Transportation', :parent_id => expenses.id}).save!
    incomes = current_user.accounts.build({:name => 'Incomes'})
    incomes.save!
      salaries = current_user.accounts.build({:name => 'Salaries', :parent_id => incomes.id}).save!
    liabilities = current_user.accounts.build({:name => 'Liabilities'})
    liabilities.save!
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = current_user.accounts.build(params[:account].except(:user_id))

    respond_to do |format|
      if @account.save
        format.html { redirect_to @account, :notice => 'Account was successfully created.' }
        format.json { render :json => @account, :status => :created, :location => @account }
      else
        format.html { render :action => "new" }
        format.json { render :json => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @account = current_user_accounts.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(params[:account])
        format.html { redirect_to accounts_path, :notice => 'Account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @account.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account = current_user_accounts.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to accounts_url }
      format.json { head :no_content }
    end
  end

  private

  def current_user_accounts
    Account.of(current_user)
  end

end
