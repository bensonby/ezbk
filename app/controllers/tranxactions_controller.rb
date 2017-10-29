require 'net/http'
require 'nokogiri'
require 'open-uri'

class TranxactionsController < ApplicationController
  before_filter :require_user
  before_filter :set_page_name

  def set_page_name
    @page_name = "transactions"
  end

  def preview_fare_kmb
    kmb_route_no = params[:kmb_route_no]
    url = 'http://m.kmb.hk/en/result.html?busno=' + kmb_route_no
    ret = '<p><a target="_blank" href="' + url + '">' + url + '</a></p>'
    kmb_doc = Nokogiri::HTML(open(url))
    unwanted_nodes = [
      'head',
      '.detailContainer td:first-child',
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

  def preview_fare_mtr
    from = params[:from]
    to = params[:to]
    from_id = get_mtr_station_id(from)
    to_id = get_mtr_station_id(to)
    if from_id == -1 or to_id == -1
      render html: ''
      return
    end
    url = 'http://www.mtr.com.hk/en/customer/jp/index.php?sid=' + from_id.to_s + '&eid=' + to_id.to_s

    # first request gets 302, need to set cookie and re-request
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    req = Net::HTTP::Get.new(uri)
    req['Cookie'] = res['Set-Cookie']
    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

    mtr_doc = Nokogiri::HTML(res.body)
    unwanted_nodes = [
      'head',
      'script',
      'img'
    ]
    mtr_doc.search(unwanted_nodes.join(", ")).each do |src|
      src.remove
    end

    ret = '<p><a target="_blank" href="' + url + '">' + url + '</a></p>'
    ret = ret + '<h3>' + from.strip + ' - ' + to.strip + '</h3>'
    mtr_doc.css('div.mtrInfoBox').each do |el|
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

  def get_mtr_station_id(station_name)
    mtr_codes = {
      "Admiralty" => 2,
      "Airport" => 47,
      "AsiaWorld-Expo" => 56,
      "Austin" => 111,
      "Causeway Bay" => 28,
      "Central" => 1,
      "Chai Wan" => 37,
      "Che Kung Temple" => 96,
      "Cheung Sha Wan" => 18,
      "Choi Hung" => 12,
      "City One" => 98,
      "Diamond Hill" => 11,
      "Disneyland Resort" => 55,
      "East Tsim Sha Tsui" => 80,
      "Fanling" => 74,
      "Fo Tan" => 69,
      "Fortress Hill" => 30,
      "Hang Hau" => 51,
      "Heng Fa Chuen" => 36,
      "Heng On" => 101,
      "HKU" => 82,
      "Hong Kong" => 39, # or 44
      "Hung Hom" => 64,
      "Jordan" => 4,
      "Kam Sheung Road" => 115,
      "Kennedy Town" => 83,
      "Kowloon Bay" => 13,
      "Kowloon Tong" => 8,
      "Kowloon" => 40, # or 45
      "Kwai Fong" => 22,
      "Kwai Hing" => 23,
      "Kwun Tong" => 15,
      "Lai Chi Kok" => 19,
      "Lai King" => 21,
      "Lam Tin" => 38,
      "Lo Wu" => 76,
      "LOHAS Park" => 57,
      "Lok Fu" => 9,
      "Lok Ma Chau" => 78,
      "Long Ping" => 117,
      "Ma On Shan" => 102,
      "Mei Foo" => 20,
      "Mong Kok East" => 65,
      "Mong Kok" => 6,
      "Nam Cheong" => 53,
      "Ngau Tau Kok" => 14,
      "North Point" => 31,
      "Olympic" => 41,
      "Po Lam" => 52,
      "Prince Edward" => 16,
      "Quarry Bay" => 32,
      "Racecourse" => 70,
      "Sai Wan Ho" => 34,
      "Sai Ying Pun" => 81,
      "Sha Tin Wai" => 97,
      "Sha Tin" => 68,
      "Sham Shui Po" => 17,
      "Shau Kei Wan" => 35,
      "Shek Kip Mei" => 7,
      "Shek Mun" => 99,
      "Sheung Shui" => 75,
      "Sheung Wan" => 26,
      "Siu Hong" => 119,
      "Sunny Bay" => 54,
      "Tai Koo" => 33,
      "Tai Po Market" => 72,
      "Tai Shui Hang" => 100,
      "Tai Wai" => 67,
      "Tai Wo Hau" => 24,
      "Tai Wo" => 73,
      "Tin Hau" => 29,
      "Tin Shui Wai" => 118,
      "Tiu Keng Leng" => 49,
      "Tseung Kwan O" => 50,
      "Tsim Sha Tsui" => 3,
      "Tsing Yi" => 42, # or 46
      "Tsuen Wan West" => 114,
      "Tsuen Wan" => 25,
      "Tuen Mun" => 120,
      "Tung Chung" => 43,
      "University" => 71,
      "Wan Chai" => 27,
      "Wong Tai Sin" => 10,
      "Wu Kai Sha" => 103,
      "Yau Ma Tei" => 5,
      "Yau Tong" => 48,
      "Yuen Long" => 116
    }
    code = mtr_codes[station_name]
    return code.nil? ? -1 : code
  end
end
