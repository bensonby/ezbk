class TransactionsController < ApplicationController
  before_filter :set_page_name

  def set_page_name
    @page_name = "transactions"
  end

  def autocomplete_transaction_tostring
    @return_list = [];
    Transaction.all.each do |t|
      ok = true
      params[:term].split.each do |s|
        if !t.tostring.downcase.include? s.downcase
          ok = false
          break
        end
      end
      @return_list.push({:id => t.id, :value => t.tostring}) if ok
    end
    render :json => @return_list
  end


  # GET /transactions
  # GET /transactions.json
  def index
    @transactions = Transaction.find(:all, :order => "transaction_date DESC, id DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @transactions }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.json
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.json
  def new
    @transaction = Transaction.new

    2.times do
      transaction_entry = @transaction.transaction_entries.build
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
  end

  # POST /transactions/quick_create
  def quick_create
    existing = Transaction.find(params[:transaction_id])
    @transaction = existing.dup
    @transaction.transaction_entries << existing.transaction_entries.collect { |t| t.dup }
    @transaction.transaction_date = params[:transaction_date]
    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, :notice => 'Transaction was successfully created.' }
        format.json { render :json => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "new" }
        format.json { render :json => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /transactions
  # POST /transactions.json
  def create
    @transaction = Transaction.new(params[:transaction])

    respond_to do |format|
      if @transaction.save
        format.html { redirect_to @transaction, :notice => 'Transaction was successfully created.' }
        format.json { render :json => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "new" }
        format.json { render :json => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.json
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to @transaction, :notice => 'Transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.json
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to transactions_url }
      format.json { head :no_content }
    end
  end
end
