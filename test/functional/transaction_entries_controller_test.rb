require 'test_helper'

class TransactionEntriesControllerTest < ActionController::TestCase
  setup do
    @transaction_entry = transaction_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:transaction_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create transaction_entry" do
    assert_difference('TransactionEntry.count') do
      post :create, :transaction_entry => {  }
    end

    assert_redirected_to transaction_entry_path(assigns(:transaction_entry))
  end

  test "should show transaction_entry" do
    get :show, :id => @transaction_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @transaction_entry
    assert_response :success
  end

  test "should update transaction_entry" do
    put :update, :id => @transaction_entry, :transaction_entry => {  }
    assert_redirected_to transaction_entry_path(assigns(:transaction_entry))
  end

  test "should destroy transaction_entry" do
    assert_difference('TransactionEntry.count', -1) do
      delete :destroy, :id => @transaction_entry
    end

    assert_redirected_to transaction_entries_path
  end
end
