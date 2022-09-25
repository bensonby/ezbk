require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'iconv'

class TranxactionsController < ApplicationController
  before_action :require_user
  before_action :set_page_name

  def set_page_name
    @page_name = "transactions"
  end

  def remove_width_styles(html)
    tmp = html.gsub(/style="(.*?)"/, "")
    return tmp.gsub(/width="(.*?)"/, "")
  end

  def preview_fare_bus
    type = params[:type]
    route_no = params[:route_no]
    case type
    when "KMB"
      url = "http://www.i-busnet.com/busroute/kmb/kmbr#{route_no.downcase}.php"
    when "LWB"
      url = "http://www.i-busnet.com/busroute/lwb/lwbr#{route_no.downcase}.php"
    when "CTB"
      url = "http://www.i-busnet.com/busroute/ctb/ctbr#{route_no.downcase}.php"
    when "NWFB"
      url = "http://www.i-busnet.com/busroute/nwfb/nwfbr#{route_no.downcase}.php"
    when "HBB"
      url = "http://www.i-busnet.com/busroute/harbour/harbourr#{route_no.downcase}.php"
    else
      render html: "Invalid bus type!"
    end
    ret = '<p><a target="_blank" href="' + url + '">' + url + '</a></p>'

    ic = Iconv.new('utf-8', 'big5')
    begin
      doc = Nokogiri::HTML(open(url), nil, 'big5')
      doc.xpath('//@src').remove  # remove dead img src
      unwanted_nodes = [
        'script',
        'img'
      ]
      doc.search(unwanted_nodes.join(", ")).each do |src|
        src.remove
      end

      # for normal routes, there are 5 <tr> nodes, 3rd and 4th are the two directions
      # for circular routes, there are 4 <tr> nodes, the 3rd is the one we need
      selectors = [
        'div#ypaAdWrapper-List4 ~ table > tr > td > table > tr:nth-child(3) > td:first-child',
        'div#ypaAdWrapper-List4 ~ table > tr > td > table > tr:nth-child(4) > td:first-child:not(:last-child)',
      ]
      doc.css(selectors.join(", ")).each do |el|
        ret = ret + '<table class="detailTable"><tr>' + ic.iconv(remove_width_styles(el.to_s)) + '</tr></table>'
      end
    rescue => e
      ret = ret + e.message
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
    url = "https://checkfare.swiftzer.net/checkfare14.php/zh/#{from_id},#{to_id}/0/0/x/0"
    mtr_doc = Nokogiri::HTML(open(url))

    ret = '<p><a target="_blank" href="' + url + '">' + url + '</a></p>'
    ret = ret + '<h3>' + from.strip + ' - ' + to.strip + '</h3>'
    mtr_doc.css('main div.rge_table table').each do |el|
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
                    order("transaction_date DESC, id DESC").distinct

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
      "Ho Man Tin" => 84,
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
      "Lei Tung" => 88,
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
      "Ocean Park" => 86,
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
      "South Horizons" => 89,
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
      "Whampoa" => 85,
      "Wong Chuk Hang" => 87,
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
