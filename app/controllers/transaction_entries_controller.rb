class TransactionEntriesController < ApplicationController
  autocomplete :account, :name
  # GET /transaction_entries
  # GET /transaction_entries.json
  def index
    @transaction_entries = TransactionEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @transaction_entries }
    end
  end

  # GET /transaction_entries/1
  # GET /transaction_entries/1.json
  def show
    @transaction_entry = TransactionEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @transaction_entry }
    end
  end

  # GET /transaction_entries/new
  # GET /transaction_entries/new.json
  def new
    @transaction_entry = TransactionEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @transaction_entry }
    end
  end

  # GET /transaction_entries/1/edit
  def edit
    @transaction_entry = TransactionEntry.find(params[:id])
  end

  # POST /transaction_entries
  # POST /transaction_entries.json
  def create
    @transaction_entry = TransactionEntry.new(params[:transaction_entry])

    respond_to do |format|
      if @transaction_entry.save
        format.html { redirect_to @transaction_entry, :notice => 'Transaction entry was successfully created.' }
        format.json { render :json => @transaction_entry, :status => :created, :location => @transaction_entry }
      else
        format.html { render :action => "new" }
        format.json { render :json => @transaction_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transaction_entries/1
  # PUT /transaction_entries/1.json
  def update
    @transaction_entry = TransactionEntry.find(params[:id])

    respond_to do |format|
      if @transaction_entry.update_attributes(params[:transaction_entry])
        format.html { redirect_to @transaction_entry, :notice => 'Transaction entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @transaction_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /transaction_entries/1
  # DELETE /transaction_entries/1.json
  def destroy
    @transaction_entry = TransactionEntry.find(params[:id])
    @transaction_entry.destroy

    respond_to do |format|
      format.html { redirect_to transaction_entries_url }
      format.json { head :no_content }
    end
  end
end
