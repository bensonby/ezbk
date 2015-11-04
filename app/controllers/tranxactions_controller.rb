require 'nokogiri'
require 'open-uri'

class TranxactionsController < ApplicationController
  before_filter :require_user
  before_filter :set_page_name

  def set_page_name
    @page_name = "transactions"
  end

  def preview_fare_kmb
    ret = ""
    kmb_route_no = params[:kmb_route_no]
    kmb_doc = Nokogiri::HTML(open('http://m.kmb.hk/en/result.html?busno=' + kmb_route_no ))
    unwanted_nodes = [
      'head',
      '.detailContainer td:nth-child(3)',
      '.detailContainer td:first-child',
      '.detailContainer th:nth-child(3)',
      '.detailContainer th:first-child',
    ]
    kmb_doc.search(unwanted_nodes.join(", ")).each do |src|
      src.remove
    end
    kmb_doc.xpath('//@src').remove  # remove dead img src
    kmb_doc.css('.navTable, .resultContainer h4, .detailContainer').each do |el|
      ret = ret + el.to_s
    end
    render html: ret.html_safe
  end

  def autocomplete_transaction_tostring
    where_sql = params[:term].split.map do |term|
                  "(tranxactions.description ilike '%#{term}%' or
                    accounts.name ilike '%#{term}%' or
                    cast(transaction_entries.debit_amount as CHAR(11)) like '%#{term}%')"
                end.join(" AND ")
    transactions = current_user_transactions.joins(:transaction_entries => :account).where(where_sql).limit(100).reduce(Hash.new) do |list, t|
      list[t.id] = t.tostring if !list.has_value?(t.tostring)
      list
    end
    @return_list = []
    transactions.each {|id,value| @return_list.push({:id => id, :value => value})}
    render :json => @return_list
  end


  # GET /tranxactions
  # GET /tranxactions.json
  def index
    start_date = params[:start_date].nil? ? "1970-01-01 00:00:00" : params[:start_date]
    end_date = params[:end_date].nil? ? "2100-01-01 00:00:00" : params[:end_date]
    @transactions = Tranxaction.of_user(current_user).
                    where("transaction_date" => (start_date)..(end_date)).
                    paginate(:page => params[:page]).
                    order("transaction_date DESC, id DESC").uniq!

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @transactions }
    end
  end

  # GET /tranxactions/1
  # GET /tranxactions/1.json
  def show
    @transaction = Tranxaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @transaction }
    end
  end

  # GET /tranxactions/new
  # GET /tranxactions/new.json
  def new
    @transaction = Tranxaction.new

    2.times do
      transaction_entry = @transaction.transaction_entries.build
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @transaction }
    end
  end

  # GET /tranxactions/1/edit
  def edit
    @transaction = Tranxaction.find(params[:id])
  end

  # POST /tranxactions/quick_create
  def quick_create
    if params[:tranxaction_id].blank?
      redirect_to tranxactions_path, :alert => 'No existing transaction selected for quick create'
      return
    end
    existing = Tranxaction.find(params[:tranxaction_id])
    @transaction = existing.dup
    @transaction.transaction_entries << existing.transaction_entries.collect { |t| t.dup }
    @transaction.transaction_date = params[:transaction_date]
    respond_to do |format|
      if @transaction.save
        if params[:edit]
          format.html { redirect_to "/tranxactions/#{@transaction.id}/edit", :notice => 'Transaction was successfully created.' }
        else
          format.html { redirect_to tranxactions_path, :notice => 'Transaction was successfully created.' }
        end
        format.json { render :json => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "new" }
        format.json { render :json => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /tranxactions
  # POST /tranxactions.json
  def create
    #@transaction = Tranxaction.new(params[:tranxaction])
    @transaction = Tranxaction.new(params.require(:tranxaction).permit(:transaction_date, :description, { transaction_entries_attributes: [:debit_amount, :tranxaction_id, :account_id]}))

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

  # PUT /tranxactions/1
  # PUT /tranxactions/1.json
  def update
    @transaction = Tranxaction.find(params[:id])

    respond_to do |format|
      if @transaction.update_attributes(params.require(:tranxaction).permit(:transaction_date, :description, { transaction_entries_attributes: [:debit_amount, :tranxaction_id, :account_id, :id, :_destroy]}))
        format.html { redirect_to @transaction, :notice => 'Transaction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tranxactions/1
  # DELETE /tranxactions/1.json
  def destroy
    @transaction = Tranxaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to tranxactions_url }
      format.json { head :no_content }
    end
  end

  private

  def current_user_transactions
    Tranxaction.of_user(current_user)
  end
end
